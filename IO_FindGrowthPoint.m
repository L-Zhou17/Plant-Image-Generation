function [a_x, a_y] = IO_FindGrowthPoint(BKG_rgb,dx,wx,dy,wy,Stem_ANN)
    Gen_SingleStem = BKG_rgb.*0;
    Gen_SingleStem(dx:dx+wx-1,dy:dy+wy-1,:) = Gen_SingleStem(dx:dx+wx-1,dy:dy+wy-1,:) + Stem_ANN;
    temp1 = Gen_SingleStem(:,:,1)>0|Gen_SingleStem(:,:,2)>0|Gen_SingleStem(:,:,3)>0;
    temp2 = imerode(temp1, strel('disk',1));
    temp3 = (temp1 - temp2)>0;
    [a_x, a_y] = find(temp3>0);
end