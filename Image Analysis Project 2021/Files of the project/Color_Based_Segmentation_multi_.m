% Αποκτάμε τις συναφείς εικόνες. Όλες απεικονίζουν από έναν σκύλο σε
% πράσινο τοπίο
source1 = imread("dog1.jpg");
source2 = imread("dog2.jpg");
source3 = imread("dog3.jpg");
subplot(1,3,1), imshow(source1);
title("Dog 1");
subplot(1,3,2), imshow(source2);
title("Dog 2");
subplot(1,3,3), imshow(source3);
title("Dog 3");

%Υπολογίζουμε τα δείγματα χρώματος στον χρωματικό χώρο L*a*b για κάθε περιοχή.
%{
Μπορούμε να δούμε έξι βασικά χρώματα στην εικόνα: το χρώμα φόντου, κόκκινο,
πράσινο, μοβ, κίτρινο και ματζέντα.

Ο χρωματικός χώρος L * a * b * (επίσης γνωστός ως CIELAB ή CIE L * a * b *) 
σας επιτρέπει να ποσοτικοποιήσετε αυτές τις οπτικές διαφορές.Ο χώρος χρωμάτων L * a * b * 
προέρχεται από τις τιμές τριχίσματος CIE XYZ. Ο χώρος L * a * b * αποτελείται 
από μια φωτεινότητα «L *» ή στρώμα φωτεινότητας, στρώμα χρωματικότητας «a *» 
που υποδεικνύει πού πέφτει το χρώμα κατά μήκος του κόκκινου-πράσινου άξονα και στρώμα 
χρωματικότητας «b *» υποδεικνύοντας πού πέφτει το χρώμα κατά μήκος του μπλε-κίτρινου άξονα.

Η προσέγγισή μας είναι να επιλέξουμε μια μικρή περιοχή δείγματος για κάθε 
χρώμα και να υπολογίσετε το μέσο χρώμα κάθε περιοχής δείγματος στο χώρο 
'a * b *'.Θα χρησιμοποιήσουμε αυτούς τους χρωματικούς δείκτες για να ταξινομήσετε
κάθε pixel.

%}

load regioncoordinates;

nColors = 6;
sample_regions1 = false([size(source1,1) size(source1,2) nColors]);
sample_regions2 = false([size(source2,1) size(source2,2) nColors]);
sample_regions3 = false([size(source3,1) size(source3,2) nColors]);

for count = 1:nColors
  sample_regions(:,:,count) = roipoly(source,region_coordinates(:,1,count), ...
                                      region_coordinates(:,2,count));
end

imshow(sample_regions(:,:,2))
title('Sample Region for Red')

% Μετατρέπουμε την εικόνα RGB προέλευσης σε εικόνα L * a * b * χρησιμοποιώντας rgb2lab
labImage = rgb2lab(source);

% Υπολογίζουμε τη μέση τιμή 'a *' και 'b *' για κάθε περιοχή που εξάγουμε με roipoly.
% Αυτές οι τιμές χρησιμεύουν ως οι χρωματικοί δείκτες μας στο διάστημα 'a * b *
AImage = labImage(:, :, 2);
BImage = labImage(:, :, 3);

color_markers = zeros([nColors, 2]);

for count = 1:nColors
  color_markers(count,1) = mean2(AImage(sample_regions(:,:,count)));
  color_markers(count,2) = mean2(BImage(sample_regions(:,:,count)));
end

% Παράδειγμα το μέσο χρώμα της κόκκινης περιοχής δείγματος στο διάστημα 'a * b *' είναι:
fprintf('[%0.3f,%0.3f] \n',color_markers(2,1),color_markers(2,2));

%%Ταξινόμηση κάθε εικονοστοιχείου χρησιμοποιώντας τον κανόνα του πλησιέστερου γείτονα
%{
Κάθε δείκτης χρώματος έχει τώρα τιμή «a *» και «b *». Μπορούμε να ταξινομήσουμε κάθε εικονοστοιχείο στην εικόνα lab_fabric υπολογίζοντας την Ευκλείδεια απόσταση
μεταξύ αυτού του pixel και κάθε χρώματος. Η μικρότερη απόσταση θα μας πει ότι το pixel ταιριάζει περισσότερο με αυτόν τον χρωματικό δείκτη.
Για παράδειγμα, εάν η απόσταση μεταξύ ενός εικονοστοιχείου και του δείκτη κόκκινου χρώματος είναι η μικρότερη, τότε το εικονοστοιχείο θα επισημαίνεται ως κόκκινο εικονοστοιχείο.
%}

% Δημιουργούμε έναν πίνακα που περιέχει τις ετικέτες χρωμάτων μας, δηλαδή, 0 = φόντο, 1 = κόκκινο, 2 = πράσινο, 3 = μοβ, 4 = ματζέντα και 5 = κίτρινο.
color_labels = 0:nColors-1;

% Αρχικοποιούμε πίνακες που θα χρησιμοποιηθούν στην ταξινόμηση του πλησιέστερου γείτονα AImage = double(AImage);
AImage = double(AImage);
BImage = double(BImage);
distance = zeros([size(AImage), nColors]);

% Εκτελούμε ταξινόμηση
for count = 1:nColors
  distance(:,:,count) = ( (AImage - color_markers(count,1)).^2 + ...
                      (BImage - color_markers(count,2)).^2 ).^0.5;
end

[~,label] = min(distance,[],3);
label = color_labels(label);
clear distance;

% Αποτελέσματα εμφάνισης της ταξινόμησης πλησιέστερου γείτονα
%{
Ο πίνακας ετικετών περιέχει μια έγχρωμη ετικέτα για κάθε pixel στην εικόνα προέλευσης Χρησιμοποιούμε τη μήτρα ετικέτας για να διαχωρίσουμε αντικείμενα στο πρωτότυπο
εικόνα πηγής ανά χρώμα. 
%}
rgb_label = repmat(label,[1 1 3]);
segmented_images = zeros([size(source), nColors],'uint8');

for count = 1:nColors
  color = source;
  color(rgb_label ~= color_labels(count)) = 0;
  segmented_images(:,:,:,count) = color;
end 

% Εμφανίζουμε τα πέντε τμηματοποιημένα χρώματα ως μοντάζ. Εμφανίζουμε επίσης 
% τα εικονοστοιχεία φόντου στην εικόνα που δεν είναι ταξινομείται ως χρώμα.
montage({segmented_images(:,:,:,2),segmented_images(:,:,:,3) ...
    segmented_images(:,:,:,4),segmented_images(:,:,:,5) ...
    segmented_images(:,:,:,6),segmented_images(:,:,:,1)});
title("Montage of Red, Green, Purple, Magenta, and Yellow Objects, and Background")

% Εμφάνιση τιμών 'a *' και 'b *' των ετικετών χρωμάτων
%{
Μπορούμε να δούμε πόσο καλά η ταξινόμηση του πλησιέστερου γείτονα διαχώρισε τους διαφορετικούς πληθυσμούς χρωμάτων σχεδιάζοντας τις τιμές «a *» και «b *»
pixel που ταξινομήθηκαν σε ξεχωριστά χρώματα. Για σκοπούς εμφάνισης, επισημάνουμε κάθε σημείο με την έγχρωμη ετικέτα του.
%}
purple = [119/255 73/255 152/255];
plot_labels = {'k', 'r', 'g', purple, 'm', 'y'};

figure
for count = 1:nColors
  plot(AImage(label==count-1),BImage(label==count-1),'.','MarkerEdgeColor', ...
       plot_labels{count}, 'MarkerFaceColor', plot_labels{count});
  hold on;
end
  
title('Scatterplot of the segmented pixels in ''a*b*'' space');
xlabel('''a*'' values');
ylabel('''b*'' values');

%--------------------------------------------------------------------------%

% Διαβάζουμε την εικόνα και την μετατρέπουμε σε χώρο χρωμάτων L * a * b *
I = imread('dog.jpg');
Ilab = rgb2lab(I);
% Εξαγωγή καναλιών a * και b * και αναδιαμόρφωση
ab = double(Ilab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
% Τμηματοποίηση χρησιμοποιόντας k-means
nColors = 6;
[cluster_idx, cluster_center] = kmeans(ab,nColors,...
  'distance',     'sqEuclidean', ...
  'Replicates',   3);
% Εμφάνιση του αποτελέσματος
pixel_labels = reshape(cluster_idx,nrows,ncols);
imshow(pixel_labels,[]), title('image labeled by cluster index')
