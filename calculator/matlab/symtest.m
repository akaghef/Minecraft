classdef symtest<sym
    methods
        function obj=symtest(a)
            obj@sym(a)
        end
        function ret=gets(obj)
            ret=obj.s;
        end
    end
end