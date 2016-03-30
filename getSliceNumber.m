function[i]=getSliceNumber(filename)
    MAXSLICES=100;
    for i=0:MAXSLICES-1
       filenameTemp=filename;filenameTemp(end-9)=num2str(i+1);
        if(exist(filenameTemp,'file')==0)
           return ; 
        end
        
    end
end