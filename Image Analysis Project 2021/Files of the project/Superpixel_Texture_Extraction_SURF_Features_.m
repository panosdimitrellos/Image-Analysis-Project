% Αποκτάμαι την εικόνα
source = imread("dog.jpg");

%source = rgb2lab(source);

[L,N] = superpixels(source,100);

BW = boundarymask(L);

outputImage = zeros(size(source), 'like', source);

%{
Θα χρησιμοποιήσω τη συνάρτηση label2idx για τον υπολογισμό των δεικτών των 
pixel σε κάθε σύμπλεγμα superpixel.
Αυτό θα μου επιτρέψει να αποκτήσω πρόσβαση στις τιμές των κόκκινων, 
πράσινων και μπλε στοιχείων χρησιμοποιώντας γραμμική ευρετηρίαση
%}
idx = label2idx(L);
numRows = size(source,1);
numCols = size(source,2);

%{
Για κάθε ένα από τα συμπλέγματα N superpixel, χρησιμοποιούμε γραμμική 
ευρετηρίαση για πρόσβαση στα κόκκινα, πράσινα και μπλε στοιχεία,
ανακατασκευάζουμε τα αντίστοιχα εικονοστοιχεία ενώ ανιχνεύουμε τα 
χαρακτηριστικά SURF για την έκδοση κλίμακας του γκρι της εικόνας
και δείχνει τα 10 ισχυρότερα από αυτά, στην εικόνα  εξόδου της κλίμακας του
γκρι.
%}
for labelVal = 1:N
	redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
	outputImage(redIdx) = source(redIdx);
    outputImage(greenIdx) = source(greenIdx);
    outputImage(blueIdx) = source(blueIdx);
	points = detectSURFFeatures(rgb2gray(outputImage));
	imshow(rgb2gray(outputImage)); hold on;
	imshow(outputImage); hold on;
	plot(points.selectStrongest(10));
end    

%-------------------------------------------------------------%
% Βρίσκουμε αντίστοιχα σημεία μεταξύ δύο εικόνων χρησιμοποιώντας τις  λειτουργίες SURF
% Διαβάζουμε τις εικόνες
img = imread('dog.jpg');
source1 = rgb2gray(img);
img2 = imread('dog2.jpg');
source2 = rgb2gray(img2);

% Εντοπισμός χαρακτηριστικών SURF
points1 = detectSURFFeatures(source1);
points2 = detectSURFFeatures(source2);


% Εξαγωγή χαρακτηριστικών
[f1, vpts1] = extractFeatures(source1, points1);
[f2, vpts2] = extractFeatures(source2, points2);

% Αντιστοίχισης χαρακτηριστικών 
indexPairs = matchFeatures(f1, f2) ;
matchedPoints1 = vpts1(indexPairs(:, 1));
matchedPoints2 = vpts2(indexPairs(:, 2));

% Οπτικοποιούμε τις υποψήφιες αντιστοιχήσεις
figure; ax = axes;
showMatchedFeatures(source1,source2,matchedPoints1,matchedPoints2,'Parent',ax);
title(ax, 'Putative point matches');
legend(ax,'Matched points 1','Matched points 2');

figure; ax = axes;
showMatchedFeatures(source1,source2,matchedPoints1,matchedPoints2,'montage','Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');

%-------------------------------------------------------------%
% Αποκτάμαι την εικόνα
img = imread('dog.jpg');
source = rgb2gray(img);

% Εξαγωγή λειτουργιών SURF από μια εικόνα
points = detectSURFFeatures(source);
[features, valid_points] = extractFeatures(source,points);

% Οπτικοποιούμε τα 10 ισχυρότερα SURF χαραλτηριστικά, συμπεριλαμβανομένων 
% των κλιμάκων και του προσανατολισμού τους που καθορίστηκαν κατά τη διαδικασία εξαγωγής περιγραφέα.
figure;
imshow(source); 
hold on;
strongestPoints = valid_points.selectStrongest(10);
strongestPoints.plot('showOrientation',true);