.class public Lcom/shanesenbradz/apstudy/MainActivity$BackCb;
.super Ljava/lang/Object;
.source "MainActivity.java"

.implements Landroid/window/OnBackInvokedCallback;

.field public a:Lcom/shanesenbradz/apstudy/MainActivity;

.method public constructor <init>(Lcom/shanesenbradz/apstudy/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/shanesenbradz/apstudy/MainActivity$BackCb;->a:Lcom/shanesenbradz/apstudy/MainActivity;
    return-void
.end method

.method public onBackInvoked()V
    .locals 1
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity$BackCb;->a:Lcom/shanesenbradz/apstudy/MainActivity;
    invoke-virtual {v0}, Lcom/shanesenbradz/apstudy/MainActivity;->onBackPressed()V
    return-void
.end method
