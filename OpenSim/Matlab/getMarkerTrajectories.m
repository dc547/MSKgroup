function [ markerStates, simTime ] = getMarkerTrajectories( direct, labelNames )
%getMarkerTrajectories Extracts virtual marker X-Y-Z position after a
%PointKinematic analysis. Returns a horizonaly contatinated matrix of XYZ*n
%number of markers
%  direct - Folder name wher the PointKinematic output is
%  labelNames - Names and number of labels of interest
% Pavlos Silvestros, University of Bath, 2017


markerStates=[];

cd(direct);
pkFileNames=dir('*_pos*.sto');

for iMarker=1:numel(labelNames)
    % read .sto files
    point=importdata([direct pkFileNames(iMarker).name]);
    
    % Get marker XYZ position
    pointXYZ=point.data(:,2:4);
    
    % Add to states matrix
    markerStates=horzcat(markerStates,pointXYZ);
    
end
 simTime=point.data(:,1);
end
