% Αποκτάμαι τις εικόνες
source1 = imread("dog.jpg");
source1 = rgb2gray(source1);
img = imread("dog1.jpg");
source2 = rgb2gray(img);

[L1,N1] = superpixels(source1,100);
[L2,N2] = superpixels(source2,100);

BW1 = boundarymask(L1);
BW2 = boundarymask(L2);

outputImage1 = zeros(size(source1), 'like', source1);
outputImage2 = zeros(size(img), 'like', img);

%{
Θα χρησιμοποιήσω τη συνάρτηση label2idx για να υπολογίσω τους δείκτες των pixel σε κάθε σύμπλεγμα superpixel.
Αυτό θα μου επιτρέψει να αποκτήσω πρόσβαση στις τιμές των κόκκινων, πράσινων και μπλε στοιχείων χρησιμοποιώντας γραμμική ευρετηρίαση
%}
idx1 = label2idx(L1);

idx2 = label2idx(L2);
numRows = size(img,1);
numCols = size(img,2);

%{
Για καθένα από τα συμπλέγματα N superpixel, χρησιμοποιούμε γραμμική ευρετηρίαση ανακατασκευάστε τα αντίστοιχα pixel,
κατά την ανίχνευση / εξαγωγή χαρακτηριστικών SURF και την εμφάνιση των 10 ισχυρότερων από αυτά, στην εικόνα σε κλίμακα του γκρι
%}
for labelVal1 = 1:N1
	Idx = idx1{labelVal1};
	outputImage1(Idx) = source1(Idx);
	points1 = detectSURFFeatures(outputImage1);
	[f1, vpts1] = extractFeatures(outputImage1, points1);
	figure(1);
	imshow(outputImage1); hold on;
	strongestPoints1 = points1.selectStrongest(10);
	strongestPoints1.plot('showOrientation',true);
	grid;
end

%{
Για καθένα από τα συμπλέγματα N superpixel, χρησιμοποιήστε γραμμική ευρετηρίαση για πρόσβαση στα κόκκινα, πράσινα και μπλε στοιχεία,
ανακατασκευάστε τα αντίστοιχα εικονοστοιχεία κατά την ανίχνευση / εξαγωγή χαρακτηριστικών SURF για την έκδοση κλίμακας του γκρι της εικόνας
και δείχνει τα 10 ισχυρότερα από αυτά, στην εικόνα κλίμακας του γκρι εξόδου
%}
for labelVal = 1:N2
	redIdx = idx2{labelVal};
    greenIdx = idx2{labelVal}+numRows*numCols;
    blueIdx = idx2{labelVal}+2*numRows*numCols;
	outputImage2(redIdx) = img(redIdx);
    outputImage2(greenIdx) = img(greenIdx);
    outputImage2(blueIdx) = img(blueIdx);
	points2 = detectSURFFeatures(rgb2gray(outputImage2));
	[f2, vpts2] = extractFeatures(rgb2gray(outputImage2), points2);
	figure(2);
	imshow(outputImage2); hold on;
	strongestPoints2 = points2.selectStrongest(10);
	strongestPoints2.plot('showOrientation',true);
	grid;
end 

% Αντιστοιχούμε τα χαρακτηριστικά και με τους δύο τρόπους.
indexPairs1 = matchFeatures(f1, f2);
indexPairs2 = matchFeatures(f2, f1);
matchedPoints1 = vpts1(indexPairs1(:, 1));
matchedPoints2 = vpts2(indexPairs1(:, 2));
matchedPoints3 = vpts1(indexPairs2(:, 2));
matchedPoints4 = vpts2(indexPairs2(:, 1));

% Οπτικοποιούμε τα υποψήφια χαρακτηριστικά
figure; ax = axes;
showMatchedFeatures(source1,source2,matchedPoints1,matchedPoints2,'Parent',ax);
showMatchedFeatures(source1,source2,matchedPoints3,matchedPoints4,'Parent',ax);
title(ax, 'Putative point matches');
legend(ax,'Matched points 1','Matched points 2');

figure; ax = axes;
showMatchedFeatures(source1,source2,matchedPoints1,matchedPoints2,'montage','Parent',ax);
showMatchedFeatures(source1,source2,matchedPoints3,matchedPoints4,'montage','Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');