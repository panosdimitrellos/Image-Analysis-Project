% Μετατρέπουμε την εικόνα RGB προέλευσης σε εικόνα L * a * b * χρησιμοποιώντας rgb2lab
labImage = rgb2lab(source);

% Υπολογίζουμε τα superpixels της εικόνας.
[L,N] = superpixels(labImage,100,'Method','slic');

% Εμφανίζουμε τα όρια του superpixel που επικαλύπτονται στην αρχική εικόνα.
figure
bw = boundarymask(L);
imshow(imoverlay(source,bw,'cyan'),'InitialMagnification',67);



% Ορίζουμε το χρώμα κάθε εικονοστοιχείου στην εικόνα εξόδου στο μέσο χρώμα RGB της περιοχής του superpixel.
outputImage = zeros(size(source),'like',source);
idx = label2idx(L);
numRows = size(source,1);
numCols = size(source,2);
for labelVal = 1:N
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    outputImage(redIdx) = mean(source(redIdx));
    outputImage(greenIdx) = mean(source(greenIdx));
    outputImage(blueIdx) = mean(source(blueIdx));
end    

figure
imshow(outputImage,'InitialMagnification',67)