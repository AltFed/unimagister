function [Map]=Create_Racing_Circuit()
%dimensioni
Sx=30;
Sy=30;
% Map == 3 start state
% Map == 2 terminal state
% Map == 1 Race
% Map == 0 out of limit
Map=zeros(Sx,Sy);
for i= 1:Sx
    for j=1:Sy
        if(j <= 20 && j >=10 && i<=28 )
            Map(i,j) = 1;
        end
        if(j <= 20 && j >=10 && i>=29 )
            Map(i,j) = 2;
        end
        if( i <= 15 && j <=10)
            Map(i,j)  = 1;
        end
        if(j == 1 && i<=15)
            Map(i,j)=3;
        end
    end
end
%2 type
% for i= 1:Sx
%     for j=1:Sy
%         if(i == j || i== j-1 || i== j+1)
%             Map(i,j)=1;
%             if(i <= 23 )
%                 Map(i+1,j)=1;
%                 Map(i+2,j)=1;
%             end
%         end
% 
%         if( j>= 21  && i ==25 )
%             Map(i,j) = 2;
%         end
%         if(j == 1  && i<=4)
%             Map(i,j)=3;
%         end
%     end
% end
end

