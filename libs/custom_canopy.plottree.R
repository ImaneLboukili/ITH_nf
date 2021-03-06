custom_canopy.plottree = function (tree, pdf = NULL, pdf.name = NULL, txt = NULL, txt.name = NULL) 
{
  if (is.null(pdf)) {
    pdf = FALSE
  }
  if (is.null(txt)) {
    txt = FALSE
  }
  if (pdf & is.null(pdf.name)) {
    stop("pdf.name has to be provided if pdf = TRUE!")
  }
  if (txt & is.null(txt.name)) {
    stop("txt.name has to be provided if txt = TRUE")
  }
  if (!is.null(pdf.name)) {
    pdf.split = strsplit(pdf.name, "\\.")[[1]]
    if (length(pdf.split) < 2 | pdf.split[2] != "pdf") {
      stop("pdf.name has to end with .pdf!")
    }
  }
  if (pdf) {
    pdf(file = pdf.name, height = 12, width = 12)
  }
  nf <- layout(matrix(c(1, 2, 3), 3, 1, byrow = TRUE), widths = c(3, 3, 3), heights = c(1.3, 1, 1), respect = TRUE)
  par(mar = c(1, 7, 1, 10))
  K = ncol(tree$Z)
  plot(tree, label.offset = 1, type = "cladogram", direction = "d", 
       show.tip.label = FALSE)
  nodelabels()
  tiplabels()
  snaedge = rep(NA, nrow(tree$sna))
  for (k in 1:nrow(tree$sna)) {
    snaedge[k] = intersect(which(tree$edge[, 1] == tree$sna[k, 2]), which(tree$edge[, 2] == tree$sna[k, 3]))
  }
  if (!is.null(tree$cna)) {
    cnaedge = rep(NA, nrow(tree$cna))
    for (k in 1:nrow(tree$cna)) {
      cnaedge[k] = intersect(which(tree$edge[, 1] == tree$cna[k, 2]), which(tree$edge[, 2] == tree$cna[k, 3]))
    }
  } else {
    cnaedge = NULL
  }
  edge.label = sort(unique(c(snaedge, cnaedge)))
  # affiche les mut en rouge
  edgelabels(paste("mut", 1:length(edge.label), sep = ""), edge.label, frame = "n", col = 2, cex = 1.2)
  # affiche Normal en bleu
  tiplabels("Normal", 1, adj = c(0.2, 1.5), frame = "n", cex = 1.2, col = 4) 
  # affiche tous les clones en bleu
  tiplabels(paste("Clone", 1:(K - 2), sep = ""), 2:(K - 1), adj = c(0.5, 1.5), frame = "n", cex = 1.2, col = 4)
  # affiche le dernier clone en bleu
  tiplabels(paste("Clone", (K - 1), sep = ""), K, adj = c(0.8, 1.5), frame = "n", cex = 1.2, col = 4)
  par(mar = c(1, 7, 0.5, 9.5))
  P = tree$P
  image(1:nrow(P), 1:ncol(P), axes = FALSE, ylab = "", xlab = "", # affiche les rectangles bleus et rouge
        P, breaks = 0:100/100, col = tim.colors(100))
  axis(4, at = 1:ncol(P), colnames(P), cex.axis = 1.2, las = 1, # label normal tumeur
       tick = FALSE)
  abline(h = seq(0.5, ncol(P) + 0.5, 1), v = seq(0.5, nrow(P) + # s??pare les rectangles par une ligne
                                                   0.5, 1), col = "grey")
  for (i in 1:nrow(P)) { # affiche les chiffres dans les rectangles
    for (j in 1:ncol(P)) {
      txt.temp <- sprintf("%0.3f", P[i, j])
      text(i, j, txt.temp, cex = 1.8, col = "white")
      # if (P[i, j] <= 0.2 | P[i, j] >= 0.95) {
      #   text(i, j, txt.temp, cex = 1, col = "white")
      # }
      # else {
      #   text(i, j, txt.temp, cex = 1)
      # }
    }
  }
  sna.name = rownames(tree$sna)
  cna.name = rownames(tree$cna)
  # plot(c(0, 1), c(0, 1), ann = FALSE, bty = "n", type = "n", xaxt = "n", yaxt = "n")
  txt.output = matrix(nrow = length(edge.label), ncol = 1)
  for (i in 1:length(edge.label)) {
    txt.temp = paste("mut", i, ": ", paste(c(sna.name[which(snaedge == edge.label[i])], cna.name[which(cnaedge == edge.label[i])]), collapse = ", "), sep = "")
    # text(x = 0, y = 0.95 - 0.1 * (i - 1), txt.temp, pos = 4, cex = 1.2)
    txt.output[i, 1] = txt.temp
  }
  if (txt) {
    write.table(txt.output, file = txt.name, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")
  }
  if (!is.null(pdf.name)) {
    # text(x = 0.5, y = 0.1, pdf.split[1], font = 2, cex = 1.2)
  }
  if (pdf) {
    dev.off()
  }
  par(mfrow = c(1, 1))
