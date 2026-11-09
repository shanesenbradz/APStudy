.class public Lcom/shanesenbradz/apstudy/MainActivity$Pad;
.super Ljava/lang/Object;
.source "MainActivity.java"

.implements Landroid/view/View$OnApplyWindowInsetsListener;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public onApplyWindowInsets(Landroid/view/View;Landroid/view/WindowInsets;)Landroid/view/WindowInsets;
    .locals 5
    invoke-static {}, Landroid/view/WindowInsets$Type;->systemBars()I
    move-result v0
    invoke-static {}, Landroid/view/WindowInsets$Type;->ime()I
    move-result v1
    or-int/2addr v0, v1
    invoke-static {}, Landroid/view/WindowInsets$Type;->displayCutout()I
    move-result v1
    or-int/2addr v0, v1
    invoke-virtual {p2, v0}, Landroid/view/WindowInsets;->getInsets(I)Landroid/graphics/Insets;
    move-result-object v0
    iget v1, v0, Landroid/graphics/Insets;->left:I
    iget v2, v0, Landroid/graphics/Insets;->top:I
    iget v3, v0, Landroid/graphics/Insets;->right:I
    iget v4, v0, Landroid/graphics/Insets;->bottom:I
    invoke-virtual {p1, v1, v2, v3, v4}, Landroid/view/View;->setPadding(IIII)V
    sget-object v0, Landroid/view/WindowInsets;->CONSUMED:Landroid/view/WindowInsets;
    return-object v0
.end method
