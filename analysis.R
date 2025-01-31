######################################################## 

# Title: RNA-seq Analysis in R
# Description: A streamlined R script for DESeq2-based RNA-seq analysis,
# GO enrichment, and visualization
# Date: January 8, 2025

######################################################## 

# 1. Setup ----

# Install required packages if they are not already installed
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager") 
}

if (!requireNamespace("DESeq2", quietly = TRUE)) {
  BiocManager::install("DESeq2") 
}

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2") 
}

if (!requireNamespace("pheatmap", quietly = TRUE)) {
  install.packages("pheatmap")
}

# Load necessary libraries
library("DESeq2")
library("dplyr")
library("ggplot2")
library("clusterProfiler")
library("org.Mm.eg.db")  # Mouse genome annotation database
library("enrichplot")
library("DOSE")
library("cowplot")
library("pheatmap")

######################################################## 

# 2. Data Import and Preparation ----

# Set working directory
setwd("~/workshop/masters/rna/results")

# Read gene expression count data
data <- read.csv('cleaned_data.csv', sep='\t')

# Set gene identifiers as row names
rownames(data) <- data$Geneid

# Remove unnecessary columns
data$X <- NULL 
data$Geneid <- NULL

# Define sample names from the dataset
sample_names <- c( "SRR7821918", "SRR7821919", "SRR7821920",
                   "SRR7821921", "SRR7821922", "SRR7821937", "SRR7821938", "SRR7821939",
                   "SRR7821949", "SRR7821950", "SRR7821951", "SRR7821952", "SRR7821953",
                   "SRR7821968", "SRR7821969", "SRR7821970" ) 

# Convert count data into a matrix for DESeq2
gene_matrix <- as.matrix(data[, sample_names])

# Read sample metadata
metadata <- read.csv("metadata.csv")

# Ensure metadata is ordered by sample names
metadata <- metadata[order(metadata$Sample),]

######################################################## 

# 3. Create DESeq2 Dataset ----

# Create a DESeq2 dataset object
dds <- DESeqDataSetFromMatrix(countData = gene_matrix, colData = metadata, design = ~ Group)

######################################################## 

# 4. Run DESeq2 ----

# Perform differential expression analysis
dds <- DESeq(dds) 
res <- results(dds)

# Print a summary of the results
summary(res)

# Filter significant genes (padj < 0.05) and remove NAs
res_filtered <- res[!is.na(res$padj) & res$padj < 0.05, ]

# Print the number of significant differentially expressed genes
length(res_filtered[, 1])

######################################################## 
# 5. Pairwise Comparisons ----

# Differential expression analysis for Lung samples
res_LUNG_ds <- results(dds, contrast = c("Group", "Lung_WT_Case", "Lung_WT_Control")) 

# Differential expression analysis for Blood samples
res_BLOOD_ds <- results(dds, contrast = c("Group","Blood_WT_Case", "Blood_WT_Control"))

# Print summaries for both contrasts
summary(res_LUNG_ds)
summary(res_BLOOD_ds)

######################################################## 

# 6. PCA Plot ----

# Perform variance stabilizing transformation for PCA analysis
vst_data <- vst(dds)

# Generate PCA plot, grouping by experimental condition
plotPCA(vst_data, intgroup = "Group")

######################################################## 

# 7. Volcano Plot ----

# Convert DESeq2 results into data frames
res_BLOOD <- as.data.frame(res_BLOOD_ds)
res_LUNG <- as.data.frame(res_LUNG_ds)

# Label samples by tissue type
res_BLOOD$tissue <- "Blood"
res_LUNG$tissue <- "Lung"

# Add gene names for plotting
res_BLOOD$gene <- rownames(res_BLOOD)
res_LUNG$gene <- rownames(res_LUNG)

# Combine the datasets for visualization
res_combined <- bind_rows(res_BLOOD, res_LUNG)

# Remove NA p-values
res_combined <- res_combined[!is.na(res_combined$padj),]

# Categorize genes based on significance and fold change
res_combined <- res_combined %>%
  mutate(significance = case_when(
    padj < 0.05 & log2FoldChange > 0 ~ "Over-Expressed",
    padj < 0.05 & log2FoldChange < 0 ~ "Under-Expressed",
    TRUE ~ "Not Significant"
  ))

# Define colors for significance groups
color_map <- c("Over-Expressed" = "red", "Under-Expressed" = "blue", "Not Significant" = "gray")

# Generate separate volcano plots for Blood and Lung samples
p_blood <- ggplot(res_combined %>% filter(tissue == "Blood"), 
                  aes(x = log2FoldChange, y = -log10(padj), color = significance)) +
  geom_point(size = 2) +
  scale_color_manual(values = color_map) +
  theme_minimal() +
  labs(title = "Volcano Plot for Blood", 
       x = "Log2 Fold Change", 
       y = "-Log10 Adjusted P-value", 
       color = "Expression Status")

p_lung <- ggplot(res_combined %>% filter(tissue == "Lung"), 
                 aes(x = log2FoldChange, y = -log10(padj), color = significance)) +
  geom_point(size = 2) +
  scale_color_manual(values = color_map) +
  theme_minimal() +
  labs(title = "Volcano Plot for Lung", 
       x = "Log2 Fold Change", 
       y = "-Log10 Adjusted P-value", 
       color = "Expression Status")

# Print volcano plots
print(p_blood)
print(p_lung)

######################################################## 

# 8. GO Enrichment Analysis ----

# Function to perform GO enrichment analysis and generate dot plots
go_plot <- function(dataset, name){
  differentially_expressed <- subset(dataset, padj < 0.05 & !is.na(padj))
  gene_ids <- differentially_expressed$gene # Assuming Ensembl IDs
  
  # Perform Gene Ontology enrichment analysis
  ego <- enrichGO(gene = gene_ids, universe = rownames(dataset), OrgDb = org.Mm.eg.db, 
                  keyType = "ENSEMBL", ont = "BP", pAdjustMethod = "BH",
                  pvalueCutoff = 0.05, qvalueCutoff = 0.2)
  
  # Generate dot plot for enriched terms
  dotplot(ego) + ggtitle(name) 
}

# Run GO enrichment analysis for Blood and Lung samples
go_plot(res_BLOOD, "GO Enrichment Analysis: Blood (BP)")
go_plot(res_LUNG, "GO Enrichment Analysis: Lung (BP)")

######################################################## 

# 9. Heatmap of Significant Genes ----

# Extract genes with significant differential expression
sig_genes <- rownames(res_filtered)[which(res_filtered$padj < 0.05)]  

# Obtain normalized gene counts
normalized_counts <- counts(dds, normalized = TRUE)

# Subset to include only significant genes
sig_counts <- normalized_counts[sig_genes, ]

# Log2 transform the data to reduce variance
log_counts <- log2(sig_counts + 1)

# Generate heatmap of differentially expressed genes
pheatmap(log_counts, 
         scale = "row",  # Standardize rows to have mean 0 and variance 1
         clustering_distance_rows = "euclidean", 
         clustering_distance_cols = "euclidean", 
         clustering_method = "complete", 
         show_rownames = TRUE, 
         show_colnames = TRUE,
         color = colorRampPalette(c("blue", "white", "red"))(50))

######################################################## 