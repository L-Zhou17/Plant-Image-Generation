function img = IO_ImageAdd(img,subimg,submsk,dx,wx,dy,wy)
    img(dx:dx+wx-1,dy:dy+wy-1,:) = img(dx:dx+wx-1,dy:dy+wy-1,:) - uint8(cat(3,submsk,submsk,submsk)).*255;
    img(dx:dx+wx-1,dy:dy+wy-1,:) = img(dx:dx+wx-1,dy:dy+wy-1,:) + subimg;
end