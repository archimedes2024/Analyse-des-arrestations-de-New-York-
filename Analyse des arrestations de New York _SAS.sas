/************************************************************************************************
|																					 Hiver 2024 |
|										TRAVAIL SAS 								  			|
|																				   				|
|						ÉQUIPE : Krystel Laudon 		- 11322759							   	|
|					 			 Heddier Alberto Soler  - 11272957							   	|
|							 	 Ahiboh Charles Koffi 	- 11318535								|
|																				   				|	
|***********************************************************************************************/

** Répertoire où se trouve les données; 
%LET path = C:\Users\a\Desktop\MAITRISE HEC\SESSION_HIVER_2024\LOGICIELS\Devoir_SAS_H24;

** Librairie;
LIBNAME devoir "&path.";

** Affichage des informations sommaires des tables de données;

PROC CONTENTS data=devoir.Adresse;
RUN;

PROC CONTENTS data=devoir.Data;
RUN;



***** Question 1 ***********************************************************************************************;

DATA Temp;
	SET devoir.Data;
	KEEP	STOP_ID 
			STOP_FRISK_DATE 
			STOP_FRISK_TIME 
			STOP_DURATION_MINUTES 
			SUSPECTED_CRIME_DESCRIPTION 
			FRISKED_FLAG 
			SEARCHED_FLAG 
			WEAPON_FOUND_FLAG 
			SUSPECT_REPORTED_AGE 
			SUSPECT_SEX 
			SUSPECT_RACE_DESCRIPTION;
RUN;

** Nombre d’observations totales ainsi que le type de chacune des variables;

PROC CONTENTS DATA=Temp; 
RUN;

/* Nous pouvons voire que nous avons 15102 observations et 11 variables qui sont de type numérique ou texte */

/*Une autre maniere d'obtenir les informations*/

/* PROC SQL pour compter le nombre d'observations */
proc sql;
    select count(*) as TotalObservations from Temp;
quit;


proc contents data=Temp out=VarTypes(keep=Name Type Length) noprint;
run;


/* Afficher la table des types de variables créée par PROC CONTENTS */
proc print data=VarTypes;
run;


***** Question 2 ***********************************************************************************************;

PROC UNIVARIATE DATA = Temp;
VAR SUSPECT_REPORTED_AGE;
HISTOGRAM;
RUN;

/* La variable SUSPECT_REPORTED_AGE est une variable numérique qui a 13391 observations et 
1711 observations manquantes (null). La distribution de la variable SUSPECT_REPORTED_AGE est 
asymétrique à droite avec des données entre 0 et 79 ans et où 75% des personnes arrêtées ont un âge 
inférieur ou égale à 36 ans. La moyenne d'age est de 29 ans(arrondie à l'entier inférieur).*/



***** Question 3 ************************************************************************************************;

DATA Temp2(DROP=STOP_FRISK_DATE STOP_FRISK_TIME FRISKED_FLAG SEARCHED_FLAG FRISKED_FLAG 
				WEAPON_FOUND_FLAG SUSPECT_REPORTED_AGE);  /*conserver les variables recodeees seuelement*/
    SET Temp(RENAME=(SUSPECT_RACE_DESCRIPTION=Race));   /*renommer SUSPECT_RACE_DESCRIPTION comme Race, mais dans 
														la table on voit SUSPECT_RACE_DESCRIPTION qui est le label*/
    	/* a. Le Mois de l'arrestation
		   le Jour de l'arrestation,
	       la Date de l'arrestation (format de date appliqué yymmdd10.)
	       et l'heure de l'arrestation */

		/* Extraction du mois, du jour et de la date d'arrestation */
	    Mois = MONTH(STOP_FRISK_DATE);
	    Jour = DAY(STOP_FRISK_DATE);
	    Date = STOP_FRISK_DATE;
	    Heure = STOP_FRISK_TIME;
	    
	    /* Application du format de date yymmdd10. à la variable Arrest_Date */
	    FORMAT Date yymmdd10. Heure time8.;


		/*b. Une variable catégorielle Quart_jour qui prend la valeur 
		« AM » si l’arrestation est effectuée avant midi, 
		« PM » sinon.*/

		LENGTH Quart_jour $ 2;     /*Lors de la création d’une variable alphanumérique de façon conditionnelle, 
									il faut porter attention à la longueur de la variable, chercher la longueur*/
		IF HOUR(STOP_FRISK_TIME) < 12 THEN Quart_jour = 'AM';  
	    ELSE Quart_jour = 'PM';


		/*c. Trois variables indicatrices Frisked, Searched, FS et Arme où
			i. Frisked prend 1 si FRISKED_FLAG = ‘Y’, 0 sinon.
			ii. Searched prend 1 si SEARCHED_FLAG = ‘Y’, 0 sinon.
			iii. FS prend 1 si FRISKED_FLAG = ‘Y’ et SEARCHED_FLAG = ‘Y’, 0 sinon. 
			iv. Arme prend 1 si WEAPON_FOUND_FLAG = ‘Y’, 0 sinon.*/
		IF FRISKED_FLAG = 'Y' THEN Frisked = 1; 
			ELSE Frisked = 0;
		IF SEARCHED_FLAG = 'Y' THEN Searched = 1; 
			ELSE Searched = 0;
		IF FRISKED_FLAG = 'Y' & SEARCHED_FLAG = 'Y' then FS = 1; 
			ELSE FS = 0;
		IF WEAPON_FOUND_FLAG = 'Y' THEN Arme = 1; 
			ELSE Arme = 0;

		/*d. Une variable catégorielle qui dénote la tranche d'âge à laquelle appartient la personne arrêtée 
		(voir Table 1). Veillez à ce que la nouvelle variable "Age_cat" soit alphanumérique.
		SUSPECT_REPORTED_AGE < =10 <=20 <=30 <=40 <=50 <=60 >60 
		Age_cat				   1	2	 3	  4	   5	 6	 7
		Vous êtes appelés à trouver un moyen de traiter les valeurs manquantes s’il y a lieu! */
	    IF SUSPECT_REPORTED_AGE = . THEN Age_cat = '0'; /* Valeur manquante */
	    ELSE IF SUSPECT_REPORTED_AGE <= 10 THEN Age_cat = '1';
	    ELSE IF SUSPECT_REPORTED_AGE <= 20 THEN Age_cat = '2';
	    ELSE IF SUSPECT_REPORTED_AGE <= 30 THEN Age_cat = '3';
	    ELSE IF SUSPECT_REPORTED_AGE <= 40 THEN Age_cat = '4';
	    ELSE IF SUSPECT_REPORTED_AGE <= 50 THEN Age_cat = '5';
	    ELSE IF SUSPECT_REPORTED_AGE <= 60 THEN Age_cat = '6';
	    ELSE Age_cat = "7"; /* Plus de 60 ans */


		 /* Exclusion des observations avec SUSPECT_RACE_DESCRIPTION (rename=race) non renseigné */
    	IF missing(Race) OR Race = '(null)' THEN delete;/*on a verifie et il y a une cathegorie null, n'oublier le end au final*/
		LABEL  Date = "Date de l'arrestation" Race = "Race";
	
RUN;


***** Question 4 ************************************************************************************************;

/*i. Le nombre de femmes arrêtées */
PROC FREQ DATA=Temp2;
TITLE "Le nombre de femmes arrêtées";
    WHERE SUSPECT_SEX = 'FEMALE'; 
    TABLES SUSPECT_SEX / nocum nopercent;
RUN;

/*ii. Le nombre d’arrestations par race identifiée*/
PROC FREQ DATA=Temp2;
TITLE "Le nombre d’arrestations par race identifiée";
    TABLES Race / nocum nopercent;
RUN;

/* iii. Le nombre total d’arrestations par mois */
PROC FREQ DATA=Temp2;
TITLE "Le nombre total d’arrestations par mois";
    TABLES Mois / nocum nopercent;
RUN;

/* iv. La durée moyenne d’une arrestation (en minutes) par quart de jour */
PROC MEANS DATA=Temp2 mean;
TITLE "La durée moyenne d’une arrestation (en minutes) par quart de jour";
    CLASS Quart_jour;
    VAR STOP_DURATION_MINUTES; 
RUN;

/* v. La fréquence des arrestations reliée aux suspicions de détention d’arme (CPW) */
PROC FREQ DATA=Temp2;
TITLE "La fréquence des arrestations reliée aux suspicions de détention d’arme (CPW)";
    WHERE SUSPECTED_CRIME_DESCRIPTION = 'CPW'; 
    TABLES SUSPECTED_CRIME_DESCRIPTION/ nocum nopercent;
RUN;


***** Question 5 ************************************************************************************************;

/* vi. Calculer les fréquences croisées (Arme* Race) et créer une table en sortie TableB 
(à même la procédure proc freq)*/
PROC FREQ DATA=Temp2; 
TABLE Race*Arme /norow nocol nopercent 
Out=TableB(drop=percent); 
RUN;

/* vii. Trier la TableB */
PROC SORT DATA=TableB; 
BY Race; 
RUN;

/* viii. Transposer la TableB pour obtenir la table désirée (TableC)*/
PROC TRANSPOSE DATA = TableB out =TableC (drop = _name_ _label_ 
										  rename=( _0=Aucune_arme _1=Arme_Found )); 
BY Race; 
ID Arme; 
VAR COUNT; 
RUN;



***** Question 6 **************************************************************************************************;

data Temp3(KEEP=STOP_ID District );  /*conserver ces variables seuelement*/
    set devoir.Adresse;  /*(rename=(SUSPECT_RACE_DESCRIPTION=Race))*/

	* Extraire ce qui se retrouve entre parenthèses;
position_deb = index(STOP_LOCATION_FULL_ADDRESS, "(");
position_fin = index(STOP_LOCATION_FULL_ADDRESS, ")");
District = substrn(STOP_LOCATION_FULL_ADDRESS, position_deb+1, position_fin-position_deb -1);
run;

PROC CONTENTS data=Temp3;
RUN;


***** Question 7 **************************************************************************************************;

proc sql;
    create table Freq_district as
    select District, 
           count(*) as Nombre_dArrestations label="Nombre d'Arrestations",
           (count(*) / (select count(*) from Temp3)) as Pourcentage_au_Total label="Pourcentage au Total" format=percent8.2
    from Temp3
    group by District;
quit;


***** Question 8 **************************************************************************************************;

proc sort data = Temp2; by STOP_ID; run;
proc sort data = Temp3; by STOP_ID; run;


data All;
    merge Temp2(in=a) Temp3(in=b);
    by STOP_ID; /* STOP_ID est la clé commune pour les deux tables */
    if a and b ; /* Ne conserve que les observations présentes dans les deux tables */
run;


/*nb d'observations des tables*/
proc sql;
title "Nombre d'observation dans la table All";
    select count(*) as TotalObservations_ALL from All;
quit;
proc sql;
title "Nombre d'observations dans la table Temp2";
    select count(*) as TotalObservations_Temp2 from Temp2;
quit;
proc sql;
title "Nombre d'observation dans la table Temp3";
    select count(*) as TotalObservations_Temp3 from Temp3;
quit;

/* Le nombre d'observations dans la table All (14910) est différent de celui de la table initial Data (15102) car la 
table All est créer en fusionnant la table Temp2 qui contient seulement les observations ayant une Race définie(14910 
sur 15102, soit 192 observations sans Race définie) et la table Temp3 qui a 15102 observation. Cependant cette fusion 
prend en compte seulement les éléments (STOP_ID) en commun aux deux table ce qui fait qu'elle ignore les 192 
observations n'ayant pas de Race. */


***** Question 9 **************************************************************************************************;

* Étape préalable d'agrégation des données;
PROC SUMMARY DATA=ALL nway missing;
  CLASS District Mois;
  VAR FS;
  OUTPUT OUT=agreg (drop=_:) sum=;
RUN;

** Table AG_FS;
/* Changer le mois de nombre en nom */

DATA agreg1 (drop = Mois
			 rename = (Moisname = Mois));
  SET agreg;					   
  Moisname = translate(upcase(put(mdy(Mois, 1, 2022), nldatemn.)), 'EU', 'ÉÛ'); *Mettre en fr en enlevant accent;
RUN;									**1 et 2022 sont des termes quelconques pour mettre sous format date 
										  et extraire le nom du mois ;
PROC SORT DATA = agreg1;
BY District;
RUN;

PROC TRANSPOSE DATA= agreg1 OUT= AG_FS (drop= _NAME_);
BY District;
ID Mois;
VAR FS; 
RUN;


** Table AG_FS1;
PROC SORT DATA=agreg; 
BY Mois; 
RUN;


PROC TRANSPOSE DATA= agreg out= AG_FS1 (drop= _NAME_);
BY Mois;
ID District;
VAR FS; 
RUN;
