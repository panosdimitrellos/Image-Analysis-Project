% Ανάγνωση εικόνας
img = imread('dog.jpg');

source = rgb2gray(img);

% Σχεδίαση σειράς φίλτρων Gabor
%{
Σχεδιάζουμε μια σειρά φίλτρων Gabor που συντονίζονται σε διαφορετικές συχνότητες και προσανατολισμούς.
Το σύνολο συχνοτήτων και προσανατολισμών έχει σχεδιαστεί για να εντοπίζει διαφορετικά, περίπου ορθογώνια,
υποσύνολα πληροφοριών συχνότητας και προσανατολισμού στην εικόνα εισαγωγής. Τακτικά δείγματα προσανατολισμών
μεταξύ [0,150] μοίρες σε βήματα των 30 μοιρών. Δείγμα μήκους κύματος σε αυξανόμενες δυνάμεις δύο εκκίνησης
από 4 / sqrt (2) έως το μήκος της εικόνας εισαγωγής.
%}
isize = size(source);
numRows = isize(1);
numCols = isize(2);

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;

deltaTheta = 45;
orientation = 0:deltaTheta:(180-deltaTheta);

c = length(wavelength);
r = length(orientation);

g = gabor(wavelength,orientation);

% Οπτικοποιούμε το πραγματικό μέρος του χωρικού πυρήνα της συνέλιξης κάθε φίλτρου Gabor στον πίνακα
figure(1);
subplot(c,r,1)
for p = 1:length(g)
    subplot(c,r,p);
    imshow(real(g(p).SpatialKernel),[]);
    lambda = g(p).Wavelength;
    theta  = g(p).Orientation;
    title(sprintf('Re[h(x,y)], \\lambda = %d, \\theta = %d',lambda,theta));
end

% Εμφάνιση των αποτελεσμάτων μεγέθους
gabormag = imgaborfilt(source,g);
outSize = size(gabormag);
gm = reshape(gabormag,[outSize(1:2),1,outSize(3)]);
figure(2), montage(gm,'DisplayRange',[]);
title('Montage of gabor magnitude output images.');

% Εμφάνιση του μεγέθους που υπολογίζεται από το φίλτρο Gabor
figure(3);
subplot(c,r,1)
for p = 1:length(g)
	[mag,phase] = imgaborfilt(source,g(p));
	subplot(c,r,p);
	imshow(mag,[])
	theta = g(p).Orientation;
    lambda = g(p).Wavelength;
	title(sprintf('Gabor magnitude\nOrientation=%d, Wavelength=%d',theta,lambda));
end

% Εμφάνιση της φάσης που υπολογίζεται από το φίλτρο Gabor
figure(4);
subplot(c,r,1)
for p = 1:length(g)
	[mag,phase] = imgaborfilt(source,g(p));
	subplot(c,r,p);
	imshow(phase,[]);
	theta = g(p).Orientation;
    lambda = g(p).Wavelength;
	title(sprintf('Gabor phase\nOrientation=%d, Wavelength=%d',theta,lambda));
end

% Μετα-επεξεργασία των εικόνων μεγέθους Gabor σε χαρακτηριστικά Gabor
%{
Για να χρησιμοποιήσουμε τις αποκρίσεις μεγέθους Gabor ως χαρακτηριστικά για χρήση στην ταξινόμηση, απαιτείται κάποια μετα-επεξεργασία.
Αυτή η επεξεργασία δημοσιεύσεων περιλαμβάνει εξομάλυνση Gauss, προσθέτοντας επιπλέον χωρικές πληροφορίες στο σύνολο χαρακτηριστικών,
αναδιαμόρφωση του συνόλου λειτουργιών μας στη φόρμα που αναμένεται από τις
συναρτήσεις pca και kmeans και ομαλοποίηση των
πληροφοριών χαρατκηριστικών σε μια κοινή διακύμανση και μέσο όρο.

Κάθε εικόνα μεγέθους Gabor περιέχει κάποιες τοπικές παραλλαγές, ακόμη και σε περιοχές με σταθερή υφή.
Αυτές οι τοπικές παραλλαγές θα απορρίψουν την τμηματοποίηση. Μπορούμε να αντισταθμίσουμε αυτές τις παραλλαγές χρησιμοποιώντας απλό
Φιλτράρισμα χαμηλού περάσματος Gauss για εξομάλυνση των πληροφοριών μεγέθους Gabor. Επιλέγουμε ένα σίγμα που ταιριάζει
στο φίλτρο Gabor που εξήγαγε κάθε δυνατότητα. Παρουσιάζουμε έναν όρο εξομάλυνσης K που ελέγχει πόσο εξομάλυνση
εφαρμόζεται στις αποκρίσεις μεγέθους Gabor.
%}
for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    K = 3;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma); 
end

%{
Κατά την κατασκευή συνόλων χαρακτηριστικών Gabor για ταξινόμηση, είναι χρήσιμο να προσθέσουμε έναν χάρτη πληροφοριών χωρικής θέσης τόσο στα Χ όσο και στα Υ.
Αυτές οι πρόσθετες πληροφορίες επιτρέπουν στον ταξινομητή να προτιμά ομαδοποιήσεις που είναι κοντά μεταξύ τους χωρικά.
%}
X = 1:numCols;
Y = 1:numRows;
[X,Y] = meshgrid(X,Y);
featureSet = cat(3,gabormag,X);
featureSet = cat(3,featureSet,Y);

%{
Αναμορφώνουμε τα δεδομένα σε έναν πίνακα X της φόρμας που αναμένεται από τη συνάρτηση kmeans. Κάθε εικονοστοιχείο στο πλέγμα εικόνας είναι ξεχωριστό σημείο δεδομένων,
και κάθε επίπεδο στο μεταβλητό χαρακτηριστικό είναι ένα ξεχωριστό χαρακτηριστικό. Σε αυτό το παράδειγμα, υπάρχει μια ξεχωριστή δυνατότητα για κάθε φίλτρο
στην τράπεζα φίλτρων Gabor, συν δύο επιπλέον δυνατότητες από τις χωρικές πληροφορίες που προστέθηκαν στο προηγούμενο βήμα.
Συνολικά, υπάρχουν 24 χαρακτηριστικά Gabor και 2 χωρικά χαρακτηριστικά για κάθε pixel στην εικόνα εισαγωγής.
%}
numPoints = numRows*numCols;
X = reshape(featureSet,numRows*numCols,[]);

% Ομαλοποίηση των χαρακτηριστικών ως μηδενικός μέσος όρος, διακύμανση μονάδας.
X = bsxfun(@minus, X, mean(X));
X = bsxfun(@rdivide,X,std(X));

%{
Οπτικοποιούμε το σύνολο δυνατοτήτων. Για να κατανοήσουμε πώς μοιάζουν τα χαρακτηριστικά μεγέθους Gabor, μπορεί να χρησιμοποιηθεί η Ανάλυση Κύριων Συστατικών
για μετακίνηση από μια αναπαράσταση 26-D κάθε εικονοστοιχείου στην εικόνα εισόδου σε τιμή έντασης 1-D για κάθε εικονοστοιχείο.
%}
coeff = pca(X);
feature2DImage = reshape(X*coeff(:,1),numRows,numCols);
figure(5)
imshow(feature2DImage,[])

% Ταξινόμηση χαρακτηριστικών υφής Gabor χρησιμοποιώντας kmeans
%{
Επαναλαμβάνουμε την ομαδοποίηση k-means πέντε φορές για να αποφύγουμε τοπικά ελάχιστα κατά την αναζήτηση μέσων που ελαχιστοποιούν την αντικειμενική λειτουργία.
Η μόνη προηγούμενη πληροφορία που υποτίθεται σε αυτό το παράδειγμα είναι πόσες διαφορετικές περιοχές υφής υπάρχουν στην εικόνα που είναι τμηματοποιημένη.
Υπάρχουν δύο διαφορετικές περιοχές σε αυτήν την περίπτωση.
%}
L = kmeans(X,2,'Replicates',5);

% Οπτικοποιούμε την τμηματοποίηση χρησιμοποιώντας label2rgb.
L = reshape(L,[numRows numCols]);
figure(6)
imshow(label2rgb(L))

%{
Οπτικοποιούμε την τμηματοποιημένη εικόνα χρησιμοποιώντας imshowpair. Εξετάζουμε τις εικόνες προσκηνίου και φόντου που προκύπτουν από τη μάσκα BW που σχετίζεται
με την ετικέτα matrix L.
%}
Aseg1 = zeros(size(img),'like',img);
Aseg2 = zeros(size(img),'like',img);
BW = L == 2;
BW = repmat(BW,[1 1 3]);
Aseg1(BW) = img(BW);
Aseg2(~BW) = img(~BW);
figure(7)
imshowpair(Aseg1,Aseg2,'montage');