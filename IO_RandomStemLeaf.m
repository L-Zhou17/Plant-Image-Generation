function [Leaf_SelectedIdx,Stem_SelectedIdx] = IO_RandomStemLeaf(Leaf_fn_list,Stem_fn_list,max_leaf)
    Leaf_RandList = randperm(length(Leaf_fn_list));
    Leaf_Num = randperm(max_leaf-2,1)+2;
    Leaf_SelectedIdx = Leaf_RandList(1:Leaf_Num);
    Stem_SelectedIdx = randperm(length(Stem_fn_list),1);
end