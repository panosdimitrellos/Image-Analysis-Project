%Βελτιστοποιούμε μια προσαρμογή ταξινόμησης SVM χρησιμοποιώντας τη βελτιστοποίηση Bayesian
%{

Αυτό το παράδειγμα δείχνει πώς να βελτιστοποιήσετε μια ταξινόμηση SVM χρησιμοποιώντας τη συνάρτηση fitcsvm και το ζεύγος τιμών-τιμών OptimizeHyperparameters.
Η ταξινόμηση λειτουργεί σε τοποθεσίες σημείων από ένα μοντέλο μείγματος Gauss.
Στο The Elements of Statistic Learning, Hastie, Tibshirani, and Friedman (2009), η σελίδα 17 περιγράφει το μοντέλο.
Το μοντέλο ξεκινά με τη δημιουργία 10 σημείων βάσης για μια "πράσινη" τάξη, διανεμημένη ως ανεξάρτητη κανονική 2-D με μέση τιμή (1,0)
και διακύμανση μονάδας. Παράγει επίσης 10 σημεία βάσης για μια "κόκκινη" τάξη, διανεμημένη ως ανεξάρτητη 2-D κανονική με μέση τιμή (0,1)
και διακύμανση μονάδας. Για κάθε τάξη (πράσινο και κόκκινο), δημιουργούμε 100 τυχαία σημεία ως εξής:

-Επιλέγουμε ένα σημείο βάσης m του κατάλληλου χρώματος ομοιόμορφα τυχαία.

- Δημιουργία ενός ανεξάρτητου τυχαίου σημείου με κανονική κατανομή 2-D με μέση τιμή m και διακύμανση I / 5, όπου I είναι ο πίνακας ταυτότητας 2 προς 2.
Σε αυτό το παράδειγμα, χρησιμοποιούμε μια διακύμανση I / 50 για να δείξουμε το πλεονέκτημα της βελτιστοποίησης με μεγαλύτερη σαφήνεια.
%}

%Δημιούργούμε τους πόντους και τον ταξινομητή
%Δημιούργούμε τα 10 σημεία βάσης για κάθε τάξη

rng default % Για αναπαραγωγιμότητα
grnpop = mvnrnd([1,0],eye(2),10);
redpop = mvnrnd([0,1],eye(2),10);

%Δείτε τα σημεία βάσης
plot(grnpop(:,1),grnpop(:,2),'go')
hold on
plot(redpop(:,1),redpop(:,2),'ro')
hold off

%Δεδομένου ότι ορισμένα κόκκινα σημεία βάσης είναι κοντά στα πράσινα σημεία βάσης, μπορεί να είναι δύσκολο να ταξινομηθούν τα σημεία δεδομένων μόνο με βάση την τοποθεσία.
%Δημιούργούμε τα 100 σημεία δεδομένων κάθε τάξης.
redpts = zeros(100,2);grnpts = redpts;
for i = 1:100
    grnpts(i,:) = mvnrnd(grnpop(randi(10),:),eye(2)*0.02);
    redpts(i,:) = mvnrnd(redpop(randi(10),:),eye(2)*0.02);
end

%Δείχνουμε τα σημεία δεδομένων.
figure
plot(grnpts(:,1),grnpts(:,2),'go')
hold on
plot(redpts(:,1),redpts(:,2),'ro')
hold off

%Προετοιμασία δεδομένων για ταξινόμηση

%Τοποθέτούμε τα δεδομένα σε μία μήτρα και δημιουργήστε μια διανυσματική ομάδα που επισημαίνει την κλάση κάθε σημείου.
cdata = [grnpts;redpts];
grp = ones(200,1);
% Πράσινη ετικέτα 1, κόκκινη ετικέτα -1
grp(101:200) = -1;

%Προετοιμασία διασταυρούμενης επικύρωσης
%Ρυθμίζουμε ένα διαμέρισμα για επικύρωση. Αυτό το βήμα διορθώνει το τρένο και τα σετ δοκιμών που χρησιμοποιεί η βελτιστοποίηση σε κάθε βήμα.

c = cvpartition(200,'KFold',10);

%Βελτιστοποιούμε το Fit

%{
Για να βρούμε μια καλή εφαρμογή, που σημαίνει μια με χαμηλή απώλεια εγκυρότητας, ορίστε επιλογές για τη χρήση βελτιστοποίησης Bayesian.
Χρησιμοποιήστε το ίδιο διαμέρισμα διασταυρούμενης επικύρωσης c σε όλες τις βελτιστοποιήσεις.
%}

%Για αναπαραγωγιμότητα, χρησιμοποίησε τη λειτουργία απόκτησης «αναμενόμενη βελτίωση-συν».
opts = struct('Optimizer','bayesopt','ShowPlots',true,'CVPartition',c,...
    'AcquisitionFunctionName','expected-improvement-plus');
svmmod = fitcsvm(cdata,grp,'KernelFunction','rbf',...
    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts)
	
%Βρίσκουμε την απώλεια του βελτιστοποιημένου μοντέλου.
lossnew = kfoldLoss(fitcsvm(cdata,grp,'CVPartition',c,'KernelFunction','rbf',...
    'BoxConstraint',svmmod.HyperparameterOptimizationResults.XAtMinObjective.BoxConstraint,...
    'KernelScale',svmmod.HyperparameterOptimizationResults.XAtMinObjective.KernelScale))
	
%Αυτή η απώλεια είναι ίδια με την απώλεια που αναφέρθηκε στην έξοδο βελτιστοποίησης στην ενότητα "Παρατηρημένη τιμή αντικειμενικής συνάρτησης".
%Οπτικοποιούμε τον βελτιστοποιημένο ταξινομητή.
d = 0.02;
[x1Grid,x2Grid] = meshgrid(min(cdata(:,1)):d:max(cdata(:,1)),...
    min(cdata(:,2)):d:max(cdata(:,2)));
xGrid = [x1Grid(:),x2Grid(:)];
[~,scores] = predict(svmmod,xGrid);
figure;
h = nan(3,1); % Preallocation
h(1:2) = gscatter(cdata(:,1),cdata(:,2),grp,'rg','+*');
hold on
h(3) = plot(cdata(svmmod.IsSupportVector,1),...
    cdata(svmmod.IsSupportVector,2),'ko');
contour(x1Grid,x2Grid,reshape(scores(:,2),size(x1Grid)),[0 0],'k');
legend(h,{'-1','+1','Support Vectors'},'Location','Southeast');
axis equal
hold off	