clear,clc,close all
root = 'dataset/';
mode = 'train';
max_leaf = 5;
num_plant = 10;

mkdir(root);mkdir([root 'images/' mode]);mkdir([root 'label_leaf/' mode]);mkdir([root 'label_stem/' mode]);
mkdir([root 'mask_leaf/' mode]);mkdir([root 'mask_stem/' mode]);mkdir([root 'mask_vein/' mode]);

Leaf_fn_list = dir('Data-Database/C*-A.png');
Leaf_fn_list = {Leaf_fn_list.name};
Stem_fn_list = dir('Data-Database/S*-A.png');
Stem_fn_list = {Stem_fn_list.name};
bk_img = 'BK-1-780-967.png';
sign_img = 'BK-1-grid.png';

pp = 1;
h = waitbar(0,'please wait...');
set(h,'doublebuffer','on');
while pp <= num_plant 
try
    waitbar(pp/num_plant,h,[num2str(pp) '/' num2str(num_plant)]);
    %% background BK1
    [BKG_rgb, Root_posX_list, Root_posY_list] = IO_BK_Gen(bk_img,sign_img);
    GEN_rgb = BKG_rgb;
    GEN_ann = BKG_rgb.*0;
    temp_plant = BKG_rgb(:,:,1).*0;
    temp_leaf = BKG_rgb(:,:,1).*0;
    temp_vein = BKG_rgb(:,:,1).*0;
    temp_stem = BKG_rgb(:,:,1).*0;
    leaf_idx = 1;
    stem_idx = 1;
    vein_idx = 1;
    fid  = fopen([root,'label_leaf/', mode ,'/',num2str(max_leaf),'-', num2str(pp),'.txt'],'a+');
    fid2 = fopen([root,'label_stem/', mode ,'/',num2str(max_leaf),'-', num2str(pp),'.txt'],'a+');
    [im_h, im_w] = size(temp_plant);
    for pot_idx = 1:4
        root_x = Root_posX_list(pot_idx);
        root_y = Root_posY_list(pot_idx);
        [Leaf_SelectedIdx,Stem_SelectedIdx] = IO_RandomStemLeaf(Leaf_fn_list,Stem_fn_list,max_leaf);
       %% Add Stem
        fn_1 = Stem_fn_list{Stem_SelectedIdx}(1:end-5);
        Stem_RGB = imread(['Data-Database/' fn_1  'I.png']);
        Stem_ANN = imread(['Data-Database/' fn_1  'A.png']);
        Stem_mask = Stem_ANN(:,:,1)>0|Stem_ANN(:,:,2)>0|Stem_ANN(:,:,3)>0;
        [dx, dy, wx, wy] = IO_CalculatePOS(Stem_mask,root_x,root_y);
        
        GEN_rgb = IO_ImageAdd(GEN_rgb,Stem_RGB,Stem_mask,dx,wx,dy,wy);
        GEN_ann = IO_ImageAdd(GEN_ann,Stem_ANN,Stem_mask,dx,wx,dy,wy);

        %--the point group ({a_x}, {a_y}) for leaf growing
        [a_x, a_y] = IO_FindGrowthPoint(BKG_rgb,dx,wx,dy,wy,Stem_ANN);
       %% Add one leaf
        rand_idx = randperm(length(a_x),length(Leaf_SelectedIdx));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        selected_x = a_x(rand_idx);
        selected_y = a_y(rand_idx);
        for kk = 1:length(Leaf_SelectedIdx)
            fn_2 = Leaf_fn_list{Leaf_SelectedIdx(kk)}(1:end-5);
            Leaf_RGB = imread(['Data-Database/' fn_2  'I.png']);
            Leaf_ANN = imread(['Data-Database/' fn_2  'A.png']);
            pos = strsplit(fn_2,'-');
            if length(pos)<=2
                continue
            end
            ex = str2num(pos{2})+1;
            ey = str2num(pos{3})+1;
            dx = selected_x(kk) - ey;
            dy = selected_y(kk) - ex;
            [wx, wy] = size(Leaf_ANN,1:2);
            
            Leaf_mask = Leaf_ANN(:,:,1)>0|Leaf_ANN(:,:,2)>0|Leaf_ANN(:,:,3)>0;

            GEN_rgb = IO_ImageAdd(GEN_rgb,Leaf_RGB,Leaf_mask,dx,wx,dy,wy);
            GEN_ann = IO_ImageAdd(GEN_ann,Leaf_ANN,Leaf_mask,dx,wx,dy,wy);

            temp_leaf(dx:dx+wx-1,dy:dy+wy-1) = temp_leaf(dx:dx+wx-1,dy:dy+wy-1) - uint8(Leaf_mask).*255;
            temp_leaf(dx:dx+wx-1,dy:dy+wy-1) = temp_leaf(dx:dx+wx-1,dy:dy+wy-1) + uint8(Leaf_mask).*leaf_idx;
            blk_leaf = temp_leaf<0;
            blk_leaf(dx:dx+wx-1,dy:dy+wy-1) = blk_leaf(dx:dx+wx-1,dy:dy+wy-1) + Leaf_mask;
            [~, leaf_ed_list] = IO_Edge2ContinueList(blk_leaf);
            fprintf(fid,'%d', 0); 
            fprintf(fid,' ');
            for NN = 1:length(leaf_ed_list)
                fprintf(fid,'%f ', leaf_ed_list(NN)); 
                fprintf(fid,' ');
            end
            fprintf(fid,'\n');
            leaf_idx = leaf_idx +1;

            vein_mask = Leaf_ANN(:,:,1)>210&Leaf_ANN(:,:,2)>210&Leaf_ANN(:,:,3)<10;
            temp_vein(dx:dx+wx-1,dy:dy+wy-1) = temp_vein(dx:dx+wx-1,dy:dy+wy-1) - uint8(vein_mask).*255;
            temp_vein(dx:dx+wx-1,dy:dy+wy-1) = temp_vein(dx:dx+wx-1,dy:dy+wy-1) + uint8(vein_mask).*vein_idx;
            blk_vein = temp_vein<0;
            blk_vein(dx:dx+wx-1,dy:dy+wy-1) = blk_vein(dx:dx+wx-1,dy:dy+wy-1) + vein_mask;
            [~, vein_ed_list] = IO_Edge2ContinueList(blk_vein);
            fprintf(fid2,'%d', 0); 
            fprintf(fid2,' ');
            for NN = 1:length(vein_ed_list)
                fprintf(fid2,'%f ', vein_ed_list(NN)); 
                fprintf(fid2,' ');
            end
            fprintf(fid2,'\n');
            vein_idx = vein_idx +1;

            stem_mask = Leaf_ANN(:,:,1)>210&Leaf_ANN(:,:,2)==0&Leaf_ANN(:,:,3)==0;
            temp_stem(dx:dx+wx-1,dy:dy+wy-1) = temp_stem(dx:dx+wx-1,dy:dy+wy-1) - uint8(stem_mask).*255;
            temp_stem(dx:dx+wx-1,dy:dy+wy-1) = temp_stem(dx:dx+wx-1,dy:dy+wy-1) + uint8(stem_mask).*stem_idx;
            blk_stem = temp_stem<0;
            blk_stem(dx:dx+wx-1,dy:dy+wy-1) = blk_stem(dx:dx+wx-1,dy:dy+wy-1) + stem_mask;
            [map, stem_ed_list] = IO_Edge2ContinueList(blk_stem);
            fprintf(fid2,'%d', 1); 
            fprintf(fid2,' ');
            for NN = 1:length(stem_ed_list)
                fprintf(fid2,'%f ', stem_ed_list(NN)); 
                fprintf(fid2,' ');
            end
            fprintf(fid2,'\n');
            stem_idx = stem_idx +1;
        end
    end
    fclose(fid);
    fclose(fid2);
    imwrite(GEN_rgb,[root,'images/', mode ,'/',num2str(max_leaf),'-',num2str(pp),'.png']);
    save([root,'mask_leaf/', mode ,'/',num2str(max_leaf),'-', num2str(pp),'.mat'], 'temp_leaf')
    save([root,'mask_stem/', mode ,'/',num2str(max_leaf),'-', num2str(pp),'.mat'], 'temp_stem')
    save([root,'mask_vein/', mode ,'/',num2str(max_leaf),'-', num2str(pp),'.mat'], 'temp_vein')
catch
    disp('...');
    continue
end
pp = pp + 1;
end

figure
subplot(221)
imshow(GEN_rgb)
subplot(222)
imagesc(temp_leaf)
subplot(223)
imagesc(temp_vein)
subplot(224)
imagesc(temp_stem)
disp(['Finished. ' num2str(num_plant) ' samples for [' mode ']. Each plant has a maximum of ' num2str(max_leaf) ' leaves.']);
