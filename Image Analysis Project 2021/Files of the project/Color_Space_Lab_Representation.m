% Αποκτάμε την εικόνα
source = imread("dog.jpg");

% Μετατρέπουμε την πηγαία RGB εικόνα σε εικόνα L * a * b * 
% χρησιμοποιώντας rgb2lab
labImage = rgb2lab(source);
 
% Παίρνουμε το κάθε κανάλι 'L*', 'a*' και 'b*' για την L*a*b* εικόνα
LImage = labImage(:, :, 1);
AImage = labImage(:, :, 2);
BImage = labImage(:, :, 3);

% Εμφανίζουμε την εικόνα L*a*b* 
subplot(4, 2, 1.5);
imshow(labImage);
title('L*a*b* Image', 'FontSize', 15);


% Εμφανίζουμε καθένα από τα κανάλια ατομικά
% και ρυθμίζοντας την απεικόνιση βασισμένη στο εύρος των τιμών των pixels
subplot(4, 2, 3);
imshow(LImage);
title('L channel Image', 'FontSize', 15);
subplot(4, 2, 4);
imshow(LImage, []);
title('L channel scaled Image', 'FontSize', 15);
subplot(4, 2, 5);
imshow(AImage);
title('A channel Image', 'FontSize', 15);
subplot(4, 2, 6);
imshow(AImage, []);
title('A channel scaled Image', 'FontSize', 15);
subplot(4, 2, 7);
imshow(BImage);
title('B channel Image', 'FontSize', 15);
subplot(4, 2, 8);
imshow(BImage, []);
title('B channel scaled Image', 'FontSize', 15);