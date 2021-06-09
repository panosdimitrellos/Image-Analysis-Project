%Σχεδίαση μεταγενέστερων περιοχών πιθανότητας για μοντέλα ταξινόμησης SVM
%{
Αυτό το παράδειγμα δείχνει πώς να προβλέψουμε τις οπίσθιες πιθανότητες των μοντέλων SVM σε ένα πλέγμα παρατηρήσεων,
και στη συνέχεια σχεδιασμός των οπίσθιων πιθανοτήτων πάνω από το πλέγμα. Η χάραξη οπίσθιας πιθανότητας εκθέτει όρια αποφάσεων.
%}

%Φόρτωση του συνόλου δεδομένων ίριδας του Fisher. Εκπαίδευση του ταξινομητή χρησιμοποιώντας τα μήκη και τα πλάτη του πέταλου και αφαίρεση των ειδών των παρθενικών δεδομένων.
load fisheriris
classKeep = ~strcmp(species,'virginica');
X = meas(classKeep,3:4);
y = species(classKeep);

%Εκπαίδευση ενός ταξινομητή SVM χρησιμοποιώντας τα δεδομένα. Είναι καλή πρακτική να καθορίζετε τη σειρά των τάξεων.
SVMModel = fitcsvm(X,y,'ClassNames',{'setosa','versicolor'});

%Υπολογίσμός της βέλτιστης συνάρτησης μετασχηματισμού βαθμολογίας.
rng(1); %Για αναπαραγωγιμότητα
[SVMModel,ScoreParameters] = fitPosterior(SVMModel); 

%Προειδοποίηση: Οι τάξεις διαχωρίζονται τέλεια. Ο βέλτιστος μετασχηματισμός από οπίσθιο σε οπίσθιο επίπεδο είναι μια συνάρτηση βημάτων.
ScoreParameters;

%{
Η βέλτιστη συνάρτηση μετασχηματισμού βαθμολογίας είναι η συνάρτηση βήματος επειδή οι τάξεις είναι διαχωρίσιμες. Τα πεδία LowerBound και UpperBound of Score
 υποδεικνύουν το κατώτερο και το ανώτερο τελικό σημείο του διαστήματος των βαθμολογιών που αντιστοιχούν στις παρατηρήσεις
εντός των υπερπλάνων διαχωρισμού τάξης (το περιθώριο). Καμία παρατήρηση κατάρτισης δεν εμπίπτει στο περιθώριο. Εάν υπάρχει νέα βαθμολογία στο διάστημα,
τότε το λογισμικό εκχωρεί στην αντίστοιχη παρατήρηση μια θετική τάξη οπίσθια πιθανότητα, δηλαδή την τιμή στο πεδίο PositiveClassProbability των ScoreParameters.

Ορίζουμε ένα πλέγμα τιμών στον παρατηρούμενο χώρο πρόβλεψης. Πρόβλεψη των οπίσθιων πιθανοτήτων για κάθε παρουσία στο πλέγμα.
%}
xMax = max(X);
xMin = min(X);
d = 0.01;
[x1Grid,x2Grid] = meshgrid(xMin(1):d:xMax(1),xMin(2):d:xMax(2));

[~,PosteriorRegion] = predict(SVMModel,[x1Grid(:),x2Grid(:)]);

%Σχεδίαση της περιοχής θετικής τάξης, της οπίσθιας πιθανότητας και των δεδομένων εκπαίδευσης
figure;
contourf(x1Grid,x2Grid,...
        reshape(PosteriorRegion(:,2),size(x1Grid,1),size(x1Grid,2)));
h = colorbar;
h.Label.String = 'P({\it{versicolor}})';
h.YLabel.FontSize = 16;
caxis([0 1]);
colormap jet;

hold on
gscatter(X(:,1),X(:,2),y,'mc','.x',[15,10]);
sv = X(SVMModel.IsSupportVector,:);
plot(sv(:,1),sv(:,2),'yo','MarkerSize',15,'LineWidth',2);
axis tight
hold off

%{
Σε εκμάθηση δύο τάξεων, εάν οι τάξεις είναι διαχωρίσιμες, τότε υπάρχουν τρεις περιοχές: μία όπου οι παρατηρήσεις έχουν θετική τάξη οπίσθια πιθανότητα 0, μία όπου είναι 1,
και μια όπου είναι η θετική τάξη προηγούμενη πιθανότητα
%}