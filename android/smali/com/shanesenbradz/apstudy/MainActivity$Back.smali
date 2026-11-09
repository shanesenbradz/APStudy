.class public Lcom/shanesenbradz/apstudy/MainActivity$Back;
.super Ljava/lang/Object;
.source "MainActivity.java"

.implements Landroid/webkit/ValueCallback;

.field public a:Lcom/shanesenbradz/apstudy/MainActivity;

.method public constructor <init>(Lcom/shanesenbradz/apstudy/MainActivity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/shanesenbradz/apstudy/MainActivity$Back;->a:Lcom/shanesenbradz/apstudy/MainActivity;
    return-void
.end method

.method public onReceiveValue(Ljava/lang/Object;)V
    .locals 2
    const-string v0, "true"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :done
    # Nothing left to go back to: send the app to the background, like other apps do.
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity$Back;->a:Lcom/shanesenbradz/apstudy/MainActivity;
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Lcom/shanesenbradz/apstudy/MainActivity;->moveTaskToBack(Z)Z
    :done
    return-void
.end method
