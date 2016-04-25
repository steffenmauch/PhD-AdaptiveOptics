
ident_static = zeros( size(ident_normalized,1), size(ident_normalized,2) );

for k=1:size(ident_normalized,1)
    
    for l=1:size(ident_normalized,2)
        num = ident_normalized(k,l).num;
        den = ident_normalized(k,l).den;
        
        num = num{1};
        den = den{1};
        
        ident_static(k,l) = num(end)/den(end);
        
    end
end
