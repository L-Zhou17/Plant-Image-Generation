function [dx, dy, wx, wy] = IO_CalculatePOS(Stem_mask,root_x,root_y)
    [XX, YY] = find(Stem_mask>0);
    [bx,aa] = max(XX);
    by = YY(aa);
    dy = root_x - by;
    dx = root_y - bx;
    [wx, wy] = size(Stem_mask);
end