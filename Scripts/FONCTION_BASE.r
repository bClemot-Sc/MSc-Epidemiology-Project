# Fonction de base 
modAppli <- function(parametre){  
  
  # CONDITIONS DE SIMULATION
  temps = 2*365;  # Nombre de pas de temps en jours
  
  # Initialisation pour la sauvegarde de 4 sorties d'indicateurs epidemiologiques pour chaque jeu de parametres
  sorties <-
    matrix(0,
           nrow = nrow(parametre),
           ncol = 4
    )
  
  
  
  # Initialisation pour la sauvegarde des matrices des effectifs par scenarios
  sortie.MAT <- list()
  
  # Initialisation pour la sauvegarde des incidences journalieres
  sortie.nvinf <- list()
  
  # Boucle des scenarios, autant que de jeux de donnees
  for (i in 1:nrow(parametre)) { 
    
    # STRUCTURE & PARAMETRES DU MODELE
    # Parametres demographiques
    K = parametre[i,1];   # Capacite d'accueil du milieu
    sr = parametre[i,2];	# Sex-ratio
    m1 = parametre[i,3];	# Mortalite naturelle de la classe d'age 1
    m2 = parametre[i,4];	# Mortalite naturelle de la classe d'age 2
    m3 = parametre[i,5];	# Mortalite naturelle de la classe d'age 3
    f2 = parametre[i,6];	# Taux de fecondite de la classe d'age 2
    f3 = parametre[i,7];	# Taux de fecondite de la classe d'age 3
    portee = parametre[i,8];	# Nombre de descendants par reproduction
    t1 = parametre[i,9];	# Taux de maturation de la classe d'age 1
    t2 = parametre[i,10];	# Taux de maturation de la classe d'age 2
    
    # Parametres epidemiologiques
    trans = parametre[i,11]; # Taux de transmission de la maladie
    lat = parametre[i,12];	# Temps d'incubation
    rec = parametre[i,13];	# Temps de recuperation
    loss = parametre[i,14];	# Temps de perte d'immunite
    madd = parametre[i,15];	# Mortalite liee a la maladie
    
    # INITIALISATION
    MAT <- array(0, dim=c(4,4,temps), dimnames = list(c("J", "A1", "A2", "total"), c("S", "E", "I", "R")));  # Matrice des effectifs de type [classe,etat,temps]
    
    nvinf <- array(0, dim=c(temps));  # Vecteur de l'incidence journaliere
    
    # Condition initiales (La population est a sa structure d'equilibre, prealablement calculee)
    MAT[1,1,1] <- 27;  # 27 JS
    MAT[2,1,1] <- 23;  # 23 A1S
    MAT[3,1,1] <- 36;  # 3 A2S
    MAT[3,3,1] <- 1;  # 1 A2I
    
    # Effectifs totaux par etat de sante
    MAT[4,1,1] <- sum(MAT[1:3,1,1]);  #S
    MAT[4,2,1] <- sum(MAT[1:3,2,1]);  #E 
    MAT[4,3,1] <- sum(MAT[1:3,3,1]);  #I 
    MAT[4,4,1] <- sum(MAT[1:3,4,1]);  #R 
    
    # SIMULATIONS
    for (t in 1:(temps-1)) {  # Boucle temps
      
      # classe d'age J
      # RQ : les naissances sont non-contaminantes, les nouveaux nes etant dans l'etat S
      N <- sum(MAT[4,,t]);	# taille de la pop en t
      MAT[1,1,t+1] <- MAT[1,1,t]*(1-m1-t1-trans*MAT[4,3,t]/N) + loss*MAT[1,4,t] + max(0, sr*portee*(sum(MAT[2,,t])*f2 + sum(MAT[3,,t])*f3) * (1 - N/K)); 
      MAT[1,2,t+1] <- MAT[1,2,t]*(1-m1-t1-lat) + trans*MAT[1,1,t]*MAT[4,3,t]/N; 
      MAT[1,3,t+1] <- MAT[1,3,t]*(1-m1-madd-t1-rec) + lat*MAT[1,2,t]; 
      MAT[1,4,t+1] <- MAT[1,4,t]*(1-m1-t1-loss) + rec*MAT[1,3,t]; 
      
      # classe d'age A1
      MAT[2,1,t+1] <- MAT[1,1,t]*t1 + MAT[2,1,t]*(1-m2-t2-trans*MAT[4,3,t]/N) + loss*MAT[2,4,t];
      MAT[2,2,t+1] <- MAT[1,2,t]*t1	+ MAT[2,2,t]*(1-m2-t2-lat) + trans*MAT[2,1,t]*MAT[4,3,t]/N;
      MAT[2,3,t+1] <- MAT[1,3,t]*t1	+ MAT[2,3,t]*(1-m2-madd-t2-rec) + lat*MAT[2,2,t];
      MAT[2,4,t+1] <- MAT[1,4,t]*t1	+ MAT[2,4,t]*(1-m2-t2-loss) + rec*MAT[2,3,t];
      
      # classe d'age 3
      MAT[3,1,t+1] <- MAT[2,1,t]*t2	+ MAT[3,1,t]*(1-m3-trans*MAT[4,3,t]/N) + loss*MAT[3,4,t];
      MAT[3,2,t+1] <- MAT[2,2,t]*t2	+ MAT[3,2,t]*(1-m3-lat)	+ trans*MAT[3,1,t]*MAT[4,3,t]/N;
      MAT[3,3,t+1] <- MAT[2,3,t]*t2	+ MAT[3,3,t]*(1-m3-madd-rec) + lat*MAT[3,2,t];
      MAT[3,4,t+1] <- MAT[2,4,t]*t2	+ MAT[3,4,t]*(1-m3-loss) + rec*MAT[3,3,t];
      
      # Calcule des effectifs totaux par etat de sante
      MAT[4,1,t+1] <- sum(MAT[1:3,1,t+1]);  #S
      MAT[4,2,t+1] <- sum(MAT[1:3,2,t+1]);  #E
      MAT[4,3,t+1] <- sum(MAT[1:3,3,t+1]);  #I
      MAT[4,4,t+1] <- sum(MAT[1:3,4,t+1]);  #R
      
      # Calcule de l'incidence journaliere
      nvinf[t+1]   <- trans*MAT[4,1,t]*MAT[4,3,t]/N
      
    }  # fin boucle temps
    
    
    
    # SORTIES PONCTUELLES
    # --- Taux de morbidite
    sortie1 <- (MAT[4,2,temps]+MAT[4,3,temps])/sum(MAT[4,,temps])
    
    # --- Incidence finale
    sortie2 <- nvinf[temps]
    
    # --- Pic infectieux (Nombre max d'infecte)
    sortie3 <- max(MAT[4,3,1:temps])
    
    # ---  Prevalence sur la premiere annee
    sortie4 <- sum(nvinf[1:365])
    
    # Integration des sorties ponctuelles a leur matrice de sortie
    sorties[i,1] <- sortie1;  # tx morbidite
    sorties[i,2] <- sortie2;  # incidence finale
    sorties[i,3] <- sortie3;  # pic infectieux
    sorties[i,4] <- sortie4;  # prevalence premiere annee
    
    # Integration des effectifs simules a leur liste de sortie
    # sortie.MAT[[i]] <- MAT
    # names(sortie.MAT)[i] <- paste0("scenario_", i)
    
    # # Integration des incidences journalieres a leur matrice de sortie
    # sortie.nvinf[[i]] <- nvinf
    # names(sortie.nvinf)[i] <- paste0("scenario_", i)
    
  }  # Fin de la boucle de scenario
  
  return(sorties)
  
  
} 


#### Parametres initiaux du modele
ValNominale = c(
  K = 100,
  sr = 0.5,
  m1 = 0.0014,
  m2 = 0.00029,
  m3 = 0.0019,
  f2 = 0.0019,
  f3 = 0.0082,
  portee = 5,
  t1 = 1 / 365,
  t2 = 1 / 365,
  trans = 0.3,
  lat = 1 / 5,
  rec = 1 / 20,
  loss = 1 / 100,
  madd = 0.001
)

