#### Analyse de senibilite avec la methode Morris et le package 'sensitivity'
#_____________________________________________________________________________

# PACKAGES
library(sensitivity)
library(ggplot2)
library(latex2exp)
library(gridExtra)
library(ggrepel)

# IMPORTATION FONCTION DE BASE ET DES VALEURS INITIALES
source("FONCTION_BASE.R")


# ANALYSE DE SENSIBILITE MORRIS -------------------------------------------
# Création des bornes minmum et maximum
bornes <- vector(mode = "list", length = 2)
bornes[[1]] <- .75 * ValNominale  # borne inférieure
bornes[[2]] <- 1.25 * ValNominale  # borne supérieure

# Fonction morris
AS.morris <- morris(
  model = modAppli,
  factors = c("K","sr","m1","m2","m3","f2","f3","portee","t1","t2","trans","lat","rec","loss","madd"),
  r = 100,  # Nombre d'itération
  design = list(
    type = 'oat',
    levels = 6,
    grid.jump = 3
  ),
  # Gamme de variation [min; max]
  binf <- bornes[[1]],
  bsup <- bornes[[2]]
)



# --- Extraction des parametres d'interet
# mu star
mu.star <- apply(abs(AS.morris$ee), 3, function(M){apply(M, 2, mean)})
# sigma
sigma <- apply(AS.morris$ee, 3, function(M){apply(M, 2, sd)})


# Dataframe
df.sorties <- data.frame(AS.morris$factors, mu.star, sigma, row.names = NULL)
colnames(df.sorties) <- c("Factors","mu.star1","mu.star2","mu.star3","mu.star4","sigma1","sigma2","sigma3","sigma4")

# Moyenne des sensibilites des 4 sorties
df.sorties$Moy.mu.star <- rowMeans(df.sorties[,2:5])
df.sorties$Moy.sigma <- rowMeans(df.sorties[,6:9])



# DISTRIBUTION DES SORTIES DU MODELES -------------------------------------
AS.morris_y <- as.data.frame(AS.morris$y)
labels_sorties <- c("Taux morbidité (t=730)", "Incidence (t=730)", "Pic infectieux", "Prévalence 1ère année" )

x11(width = 14)
par(mfrow = c(1, 4))
line<-par(lwd=2)
for (i in 1:4) {
  hist(
    AS.morris_y[, i],
    col = "#DCE1EA",
    freq = T,
    border = "black",
    xlab = NULL,
    ylab = NULL,
    main = labels_sorties[i],
    family = "serif",
    cex.lab = 2,
    cex.axis = 2,
    cex.main = 2.4
  )
  abline(v = m0[i], lty = 2, col = "red")
  
}

# VISUALISATION GRAPHIQUE MU/SIGMA -----------------------------------------------------------
# On remplace le nom des paramètres par leur symbole LaTeX
tex_label <- c(
  TeX("$K$"),
  TeX("$\\psi$"),
  TeX("$m_L$"),
  TeX("$m_J$"),
  TeX("$m_A$"),
  TeX("$f_J$"),
  TeX("$f_A$"),
  TeX("$\\Theta$"),
  TeX("$\\tau_L$"),
  TeX("$tau_J$"),
  TeX("$\\beta$"),
  TeX("$\\sigma$"),
  TeX("$\\gamma$"),
  TeX("$\\lambda$"),
  TeX("$\\mu$")
)

df.sorties["Factors_tex"] <- factor(x = df.sorties$Factors, levels = df.sorties$Factors, labels = tex_label)  # Nouvelle variable avec expression latex


# Premiere sortie - Taux de morbidite
plot1 <- ggplot(data = df.sorties, aes(x = mu.star1, y = sigma1)) +
  geom_point(size = .7) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", lwd = .4) +
  geom_abline(intercept = 0, slope = .2, linetype = "dashed", color = "black", lwd = .4) +
  geom_text_repel(
    aes(label = Factors_tex),
    show_guide = FALSE,
    max.overlaps = 5,
    parse = T,
    size = 5, direction = "y"
  ) +  # parse sert à interpréter le code latex
  scale_x_continuous(limits = c(-0.01, max(df.sorties$mu.star1) + .05*max(df.sorties$mu.star1))) +
  scale_y_continuous(limits = c(-0.001,max(df.sorties$sigma1) + .05*max(df.sorties$mu.star1))) +
  ggtitle("Graphique de Morris - Taux de morbidite (Sortie 1)") +
  xlab(TeX("$\\mu^*$")) +
  ylab(TeX("$\\sigma$")) +
  theme_classic() +
  ggtitle("Taux de morbidité t=730") +
  theme(plot.title = element_text(size = 16), text = element_text(size = 16, family = "serif")) # taille du titre

# Deuxieme sortie : Incidence finale
plot2 <- ggplot(data = df.sorties, aes(x = mu.star2, y = sigma2)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", lwd = .4) +
  geom_abline(intercept = 0, slope = .2, linetype = "dashed", color = "black", lwd = .4) +
  geom_point(size = .7) +
  geom_text_repel(
    aes(label = Factors_tex),
    show_guide = FALSE,
    max.overlaps = 9,
    parse = T, size = 5, direction = "both"
  ) +
  scale_x_continuous(limits = c(-0.01, max(df.sorties$mu.star2) + .05*max(df.sorties$mu.star2))) +
  scale_y_continuous(limits = c(-0.001,max(df.sorties$sigma2) + .05*max(df.sorties$mu.star2))) +
  ggtitle("Graphique de Morris - Incidence finale (Sortie 2)") +
  xlab(TeX("$\\mu^*$")) +
  ylab(TeX("$\\sigma$")) +
  theme_classic() +
  ggtitle("Incidence t=730") +
  theme(plot.title = element_text(size = 16), text = element_text(size = 16, family = "serif")) # taille du titre

# Troisieme sortie : Pic infectieux
plot3 <- ggplot(data = df.sorties, aes(x = mu.star3, y = sigma3)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", lwd = .4) +
  geom_abline(intercept = 0, slope = .2, linetype = "dashed", color = "black", lwd = .4) +
  geom_point(size = .7) +
  geom_text_repel(
    aes(label = Factors_tex),
    show_guide = FALSE,
    max.overlaps = 5,
    parse = T, size = 5, direction = "both"
  ) +
  scale_x_continuous(limits = c(-0.01, max(df.sorties$mu.star3) + .06*max(df.sorties$mu.star3))) +
  scale_y_continuous(limits = c(-0.001,max(df.sorties$sigma3) + .06*max(df.sorties$mu.star3))) +
  ggtitle("Graphique de Morris - Pic infectieux (Sortie 3)") +
  xlab(TeX("$\\mu^*$")) +
  ylab(TeX("$\\sigma$")) +
  theme_classic() +
  ggtitle("Pic infectieux") +
  theme(plot.title = element_text(size = 16), text = element_text(size = 16, family = "serif")) # taille du titre

# Quatrieme sortie : Prevalence de la premiere annee
plot4 <- ggplot(data = df.sorties, aes(x = mu.star4, y = sigma4)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", lwd = .4) +
  geom_abline(intercept = 0, slope = .2, linetype = "dashed", color = "black", lwd = .4) +
  geom_point(size = .7) +
  geom_text_repel(
    aes(label = Factors_tex) ,
    show_guide = FALSE,
    max.overlaps = 7,
    parse = T, size = 5, direction = "both"
  ) + 
  scale_x_continuous(limits = c(-0.01, max(df.sorties$mu.star4) + .05*max(df.sorties$mu.star4))) +
  scale_y_continuous(limits = c(-0.001,max(df.sorties$sigma4)+ .05*max(df.sorties$mu.star4))) +
  ggtitle("Graphique de Morris - Prevalence de la premiere annee (Sortie 4)") +
  xlab(TeX("$\\mu^*$")) +
  ylab(TeX("$\\sigma$")) +
  theme_classic() +
  ggtitle("Prévalence 1ère année") +
  theme(plot.title = element_text(size = 16), text = element_text(size = 16, family = "serif")) # taille du titre

x11(width = 11, height = 9)
grid.arrange(plot1, plot2, plot3, plot4, ncol = 2, nrow = 2)



# VISUALISATION ~ SORTIES -----------------------------------------------------------
sample_morris <- AS.morris$X
sorties_morris <- AS.morris$y
colnames(sample_morris) <- tex_label


# VISUALISATION THEORIQUE -------------------------------------------------
# Echantillonnage théorie
par(mfrow=c(1,1))
plot(
  sample_morris[, 2],
  sample_morris[, 11],
  main = NULL,
  xlab = TeX("$\\phi$"),
  ylab = TeX("$\\beta$"),
  family = "serif",
  cex.lab = 1.1,
  pch = 19)


# Répartition espace de points 2 à 2
par(mfrow = c(1 , 1))
plot(
  sample_morris[, 1] ~ sample_morris[,4],
  main = NULL,
  xlab = "Paramètre i",
  ylab = "Paramètre j",
  family = "serif")

# Répartition espace de point 3*3
library(rgl)
plot3d(x = sample_morris[, 1],
       y = sample_morris[, 2],
       z = sample_morris[, 11],
       xlab = TeX("K"),
       ylab = TeX("\\phi"),
       zlab = TeX("\\beta"), 
       cex.lab = 6,
       pch = 19,
       size = 5,  # taille des points
       )

# Distribution des valeurs testées
tex_label <- c(
  "$K$",
  "$\\psi$",
  "$m_L$",
  "$m_J$",
  "$m_A$",
  "$f_J$",
  "$f_A$",
  "$\\Theta$",
  "$\\tau_L$",
  "$tau_J$",
  "$\\beta$",
  "$\\sigma$",
  "$\\gamma$",
  "$\\lambda$",
  "$\\mu$"
)

par(mfrow = c(2, 2))
for (i in sample(x = 1:15, size = 15, replace = F)) {
  hist(
    sample_morris[, i],
    col = "white",
    freq = T,
    border = "black",
    breaks = 6,
    xlab = "",
    main = TeX(tex_label[i]),
    family = "serif"
  )
}

