function [BKG_rgb, Root_posX_list, Root_posY_list] = IO_BK_Gen(bk_img,sign_img)
    BKG_rgb = imread(bk_img);
    BKG_sgn = imread(sign_img);
    sn_r = 150 + randperm(60,1);
    sn_c = 600 + randperm(60,1);
    BKG_rgb(sn_r:sn_r+85,sn_c:sn_c+86,:) = BKG_rgb(sn_r:sn_r+85,sn_c:sn_c+86,:) - cat(3,uint8(im2bw(BKG_sgn)).*255,uint8(im2bw(BKG_sgn)).*255,uint8(im2bw(BKG_sgn)).*255);
    BKG_rgb(sn_r:sn_r+85,sn_c:sn_c+86,:) = BKG_rgb(sn_r:sn_r+85,sn_c:sn_c+86,:) + BKG_sgn;
    Root_posX_list = [238,487,780,1027]+randperm(12,4);
    Root_posY_list = [978,973,980,963]+randperm(12,4);
end