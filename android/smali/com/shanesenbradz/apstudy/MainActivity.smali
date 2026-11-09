.class public Lcom/shanesenbradz/apstudy/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"

.field public web:Landroid/webkit/WebView;
.field public fileCb:Landroid/webkit/ValueCallback;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 5
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity;->web:Landroid/webkit/WebView;

    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDatabaseEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowFileAccess(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setAllowContentAccess(Z)V

    invoke-virtual {v1}, Landroid/webkit/WebSettings;->getUserAgentString()Ljava/lang/String;
    move-result-object v2
    const-string v3, " APStudyApp/3.4.4"
    invoke-virtual {v2, v3}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setUserAgentString(Ljava/lang/String;)V

    new-instance v1, Lcom/shanesenbradz/apstudy/MainActivity$Client;
    invoke-direct {v1}, Lcom/shanesenbradz/apstudy/MainActivity$Client;-><init>()V
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebViewClient(Landroid/webkit/WebViewClient;)V

    new-instance v1, Lcom/shanesenbradz/apstudy/MainActivity$Chrome;
    invoke-direct {v1, p0}, Lcom/shanesenbradz/apstudy/MainActivity$Chrome;-><init>(Lcom/shanesenbradz/apstudy/MainActivity;)V
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setWebChromeClient(Landroid/webkit/WebChromeClient;)V

    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->setBackgroundColor(I)V

    # The WebView sits in a frame. On Android 15+ (edge-to-edge) the frame is
    # padded by the system bars, cutout and keyboard so nothing hides under them.
    new-instance v1, Landroid/widget/FrameLayout;
    invoke-direct {v1, p0}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V
    invoke-virtual {v1, v0}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;)V

    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v3, 0x23
    if-lt v2, v3, :no_pad
    new-instance v4, Lcom/shanesenbradz/apstudy/MainActivity$Pad;
    invoke-direct {v4}, Lcom/shanesenbradz/apstudy/MainActivity$Pad;-><init>()V
    invoke-virtual {v1, v4}, Landroid/widget/FrameLayout;->setOnApplyWindowInsetsListener(Landroid/view/View$OnApplyWindowInsetsListener;)V
    :no_pad

    invoke-virtual {p0, v1}, Lcom/shanesenbradz/apstudy/MainActivity;->setContentView(Landroid/view/View;)V

    # Android 13+: predictive back. Older versions use onBackPressed below.
    const/16 v3, 0x21
    if-lt v2, v3, :no_cb
    invoke-virtual {p0}, Lcom/shanesenbradz/apstudy/MainActivity;->getOnBackInvokedDispatcher()Landroid/window/OnBackInvokedDispatcher;
    move-result-object v3
    new-instance v4, Lcom/shanesenbradz/apstudy/MainActivity$BackCb;
    invoke-direct {v4, p0}, Lcom/shanesenbradz/apstudy/MainActivity$BackCb;-><init>(Lcom/shanesenbradz/apstudy/MainActivity;)V
    const/4 v2, 0x0
    invoke-interface {v3, v2, v4}, Landroid/window/OnBackInvokedDispatcher;->registerOnBackInvokedCallback(ILandroid/window/OnBackInvokedCallback;)V
    :no_cb

    const-string v1, "https://appassets.androidplatform.net/index.html"
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    return-void
.end method

.method public onBackPressed()V
    .locals 3
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity;->web:Landroid/webkit/WebView;
    if-nez v0, :has_web
    const/4 v1, 0x1
    invoke-virtual {p0, v1}, Lcom/shanesenbradz/apstudy/MainActivity;->moveTaskToBack(Z)Z
    return-void

    :has_web
    const-string v1, "!!(window.apsBack&&window.apsBack())"
    new-instance v2, Lcom/shanesenbradz/apstudy/MainActivity$Back;
    invoke-direct {v2, p0}, Lcom/shanesenbradz/apstudy/MainActivity$Back;-><init>(Lcom/shanesenbradz/apstudy/MainActivity;)V
    invoke-virtual {v0, v1, v2}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    return-void
.end method

.method public openChooser(Landroid/webkit/ValueCallback;Landroid/webkit/WebChromeClient$FileChooserParams;)Z
    .locals 6
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity;->fileCb:Landroid/webkit/ValueCallback;
    if-eqz v0, :fresh
    const/4 v1, 0x0
    invoke-interface {v0, v1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V

    :fresh
    iput-object p1, p0, Lcom/shanesenbradz/apstudy/MainActivity;->fileCb:Landroid/webkit/ValueCallback;

    const-string v0, "*/*"
    invoke-virtual {p2}, Landroid/webkit/WebChromeClient$FileChooserParams;->getAcceptTypes()[Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :pick
    array-length v2, v1
    const/4 v3, 0x0

    :loop
    if-ge v3, v2, :pick
    aget-object v4, v1, v3
    if-eqz v4, :next
    const-string v5, "image"
    invoke-virtual {v4, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v5
    if-eqz v5, :next
    const-string v0, "image/*"

    :next
    add-int/lit8 v3, v3, 0x1
    goto :loop

    :pick
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.GET_CONTENT"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v2, "android.intent.category.OPENABLE"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {v1, v0}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    :try_start_0
    const/4 v2, 0x7
    invoke-virtual {p0, v1, v2}, Lcom/shanesenbradz/apstudy/MainActivity;->startActivityForResult(Landroid/content/Intent;I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const/4 v0, 0x1
    return v0

    :catch_0
    move-exception v0
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity;->fileCb:Landroid/webkit/ValueCallback;
    const/4 v1, 0x0
    if-eqz v0, :cleared
    invoke-interface {v0, v1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
    :cleared
    iput-object v1, p0, Lcom/shanesenbradz/apstudy/MainActivity;->fileCb:Landroid/webkit/ValueCallback;
    const/4 v0, 0x0
    return v0
.end method

.method protected onActivityResult(IILandroid/content/Intent;)V
    .locals 5
    const/4 v0, 0x7
    if-eq p1, v0, :mine
    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onActivityResult(IILandroid/content/Intent;)V
    return-void

    :mine
    iget-object v0, p0, Lcom/shanesenbradz/apstudy/MainActivity;->fileCb:Landroid/webkit/ValueCallback;
    if-eqz v0, :done
    invoke-static {p2, p3}, Landroid/webkit/WebChromeClient$FileChooserParams;->parseResult(ILandroid/content/Intent;)[Landroid/net/Uri;
    move-result-object v1
    if-eqz v1, :deliver

    # Copy each picked file into the app's cache first. Gallery links can
    # report a size that doesn't match their bytes, and the WebView then
    # refuses to read them (NotReadableError). A plain copy always matches.
    array-length v2, v1
    const/4 v3, 0x0
    :fix_loop
    if-ge v3, v2, :deliver
    aget-object v4, v1, v3
    invoke-virtual {p0, v4}, Lcom/shanesenbradz/apstudy/MainActivity;->copyToCache(Landroid/net/Uri;)Landroid/net/Uri;
    move-result-object v4
    aput-object v4, v1, v3
    add-int/lit8 v3, v3, 0x1
    goto :fix_loop

    :deliver
    invoke-interface {v0, v1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
    const/4 v1, 0x0
    iput-object v1, p0, Lcom/shanesenbradz/apstudy/MainActivity;->fileCb:Landroid/webkit/ValueCallback;

    :done
    return-void
.end method

.method public copyToCache(Landroid/net/Uri;)Landroid/net/Uri;
    .locals 10
    :try_start_0
    invoke-virtual {p0}, Lcom/shanesenbradz/apstudy/MainActivity;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0

    # keep the original file name (Telegram's IMG_..._294.PNG stays a .PNG)
    const-string v1, "picked-file"
    move-object v2, v0
    move-object v3, p1
    const/4 v4, 0x0
    const/4 v5, 0x0
    const/4 v6, 0x0
    const/4 v7, 0x0
    invoke-virtual/range {v2 .. v7}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v2
    if-eqz v2, :no_cursor
    invoke-interface {v2}, Landroid/database/Cursor;->moveToFirst()Z
    move-result v3
    if-eqz v3, :close_cursor
    const-string v3, "_display_name"
    invoke-interface {v2, v3}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v3
    if-ltz v3, :close_cursor
    invoke-interface {v2, v3}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :close_cursor
    move-object v1, v3
    :close_cursor
    invoke-interface {v2}, Landroid/database/Cursor;->close()V
    :no_cursor
    const/16 v3, 0x2f
    const/16 v4, 0x5f
    invoke-virtual {v1, v3, v4}, Ljava/lang/String;->replace(CC)Ljava/lang/String;
    move-result-object v1

    # cache/picked holds only the latest pick
    new-instance v2, Ljava/io/File;
    invoke-virtual {p0}, Lcom/shanesenbradz/apstudy/MainActivity;->getCacheDir()Ljava/io/File;
    move-result-object v3
    const-string v4, "picked"
    invoke-direct {v2, v3, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v3
    if-eqz v3, :cleaned
    array-length v4, v3
    const/4 v5, 0x0
    :del_loop
    if-ge v5, v4, :cleaned
    aget-object v6, v3, v5
    invoke-virtual {v6}, Ljava/io/File;->delete()Z
    add-int/lit8 v5, v5, 0x1
    goto :del_loop
    :cleaned
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    new-instance v3, Ljava/io/File;
    invoke-direct {v3, v2, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;
    move-result-object v4
    if-eqz v4, :fail
    new-instance v5, Ljava/io/FileOutputStream;
    invoke-direct {v5, v3}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const/high16 v6, 0x10000
    new-array v6, v6, [B
    :copy_loop
    invoke-virtual {v4, v6}, Ljava/io/InputStream;->read([B)I
    move-result v7
    if-lez v7, :copied
    const/4 v8, 0x0
    invoke-virtual {v5, v6, v8, v7}, Ljava/io/FileOutputStream;->write([BII)V
    goto :copy_loop
    :copied
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    invoke-virtual {v5}, Ljava/io/FileOutputStream;->close()V
    invoke-static {v3}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;
    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :fail
    return-object v0

    # anything goes wrong: hand the WebView the original link, as before
    :fail
    return-object p1
.end method
