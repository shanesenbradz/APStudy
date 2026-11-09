.class public Lcom/shanesenbradz/apstudy/MainActivity$Chrome;
.super Landroid/webkit/WebChromeClient;
.source "MainActivity.java"

.field public a:Lcom/shanesenbradz/apstudy/MainActivity;

.method public constructor <init>(Lcom/shanesenbradz/apstudy/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Landroid/webkit/WebChromeClient;-><init>()V
    iput-object p1, p0, Lcom/shanesenbradz/apstudy/MainActivity$Chrome;->a:Lcom/shanesenbradz/apstudy/MainActivity;
    return-void
.end method

.method public onShowFileChooser(Landroid/webkit/WebView;Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    .locals 1
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity$Chrome;->a:Lcom/shanesenbradz/apstudy/MainActivity;
    invoke-virtual {v0, p2, p3}, Lcom/shanesenbradz/apstudy/MainActivity;->openChooser(Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    move-result v0
    return v0
.end method
