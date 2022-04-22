%{
This code generates a 2D TRIANGULAR LATTICE coordInitial/connection matix/beamCount/ Ncoord To feed
the ALGORITHM_MAIN_FILE_OPTIMIZATION

%% Outputs
nCoord
locDefault
nLinks
conMatrix
%}
function [nCoord, locDefault, conMatrix, bound, inputNodes, outputNodes] = triangleLatticeFunction(nIO, nColumns, doi, linkLength)
    nCoord = nIO + nColumns + 2*nIO*nColumns;
    nLinks = 5*nIO*nColumns + (nIO - 1)*(nColumns - 1); %5 per dimond + 1 connecting
    locDefault = zeros(nCoord, doi); %Holds default position coord of each node
    conMatrix = zeros(nLinks, 2); %Holds the start and end nodes of each link
    bound=[1:nColumns nCoord-nColumns+1:nCoord]; %[Clamped Nodes]
    %% Generate coordinate positions
    xStep = linkLength;
    yStep = linkLength*sin(pi/3);
    staggerOffset = linkLength*cos(pi/3);
    maxRowNumber = nIO*2 + 1; %(short and Long for each IO) + 1 grounded on top

    longRow = false;
    node = 1;
    column = 1;
    % place EACH coordinate
    for row = 1:maxRowNumber
        yPos = yStep*(row - 1);
        while column <= nColumns + longRow
            firstPos = staggerOffset*(~longRow); %if not longRow shift Right
            xPos = firstPos + (column-1)*xStep;
            locDefault(node, [1,2]) = [xPos,yPos];

            node = node + 1;
            column = column + 1;
        end
        column = 1; %reset the column counter
        longRow = ~longRow; %if on long row then you are on short etc
    end

    %% Generate Connectivity Matrix
    link = 1;
    rowTypes = 4;
    linkRows = (maxRowNumber-2) + (maxRowNumber - 1); % (1 horizontal for each layer except first and last 1 between each pt)
    for row = 1:linkRows
       type = mod(row-1, rowTypes);
       if type == 0 %Downward triangles (nodes at bottom)
          node = 1 + (2*nColumns + 1)*(row-1)/rowTypes;
          for column = 1:nColumns    
            conMatrix(link,:) = [node, node+nColumns]; %Left Pointing 
            conMatrix(link +1 ,:) = [node, node+nColumns + 1]; %Right Pointing
            link = link + 2;
            node = node + 1;
          end
       elseif type == 1 %LONG HORIZONTAL
           node = (nColumns + 1) + (2*nColumns + 1)*(row - type - 1)/rowTypes;
           for column = 1:(nColumns)
               conMatrix(link,:) = [node, node + 1]; %Drirectly Left
               link = link + 1;
               node = node + 1;
           end
       elseif type == 2 %upwards Triangles (nodes at TOP)
           node = (2*nColumns + 2) + (2*nColumns + 1)*(row - type -1)/rowTypes;
           for column = 1:nColumns
                conMatrix(link,:) = [node - (nColumns + 1), node];
                conMatrix(link + 1,:) = [node - (nColumns), node];
                link = link + 2;
                node = node + 1;
           end
       elseif type == 3 %Short Horizontal
           node = (2*nColumns + 2) + (2*nColumns + 1)*(row - type - 1)/rowTypes;
           for column = 1:(nColumns-1)
                          conMatrix(link,:) = [node, node + 1];
               link = link + 1;
               node = node + 1;
           end
       else
            error('Connectivity mtrix entered unknown state')
       end
    end
%%
    inputNodes = (nColumns + 1):(2*nColumns + 1): (nCoord-nColumns);
    outputNodes = inputNodes + ones(size(inputNodes))*nColumns;
    %% Plot Nodes and Neurons/links 
%     figure(1)
%     clf
%     plot(locDefault(:,1),locDefault(:,2),'ro')
%     hold on; 
%     for index = 1:length(conMatrix)
%     plot(locDefault(conMatrix(index,:),1),locDefault(conMatrix(index,:),2))
%     end
%     axis equal
end