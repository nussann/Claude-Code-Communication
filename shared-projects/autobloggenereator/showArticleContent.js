// 記事全文表示機能
async function showArticleContent(articleId) {
    try {
        // エラーハンドリング付きのFetch APIで記事データを取得
        const response = await fetch(`/api/articles/${articleId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
            }
        });

        if (!response.ok) {
            if (response.status === 404) {
                throw new Error('記事が見つかりませんでした');
            } else if (response.status === 500) {
                throw new Error('サーバーエラーが発生しました');
            } else {
                throw new Error(`記事取得エラー: ${response.status}`);
            }
        }

        const article = await response.json();
        
        // 取得したデータの検証
        if (!article || !article.id) {
            throw new Error('無効な記事データが返されました');
        }

        // モーダルウィンドウを作成して記事内容を表示
        createArticleContentModal(article);

    } catch (error) {
        console.error('記事取得エラー:', error);
        showNotification(`記事の取得に失敗しました: ${error.message}`, 'error');
    }
}

// 記事全文表示用のモーダル作成
function createArticleContentModal(article) {
    // 既存のモーダルを削除
    const existingModal = document.getElementById('article-content-modal');
    if (existingModal) {
        existingModal.remove();
    }

    // モーダルオーバーレイを作成
    const modalOverlay = document.createElement('div');
    modalOverlay.id = 'article-content-modal';
    modalOverlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 10001;
        overflow-y: auto;
        padding: 2rem;
    `;

    // モーダル本体を作成
    const modal = document.createElement('div');
    modal.style.cssText = `
        background: white;
        border-radius: 10px;
        padding: 0;
        max-width: 900px;
        width: 100%;
        max-height: 90vh;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        position: relative;
        display: flex;
        flex-direction: column;
    `;

    // モーダルヘッダー
    const header = document.createElement('div');
    header.style.cssText = `
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 1.5rem 2rem;
        border-bottom: 2px solid #f0f0f0;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    `;

    const title = document.createElement('h2');
    title.textContent = article.title;
    title.style.cssText = 'margin: 0; color: white; font-size: 1.3rem; word-wrap: break-word;';

    const closeBtn = document.createElement('button');
    closeBtn.innerHTML = '✕';
    closeBtn.style.cssText = `
        background: rgba(255,255,255,0.2);
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: white;
        padding: 0.5rem;
        border-radius: 50%;
        transition: background 0.3s;
        flex-shrink: 0;
        margin-left: 1rem;
    `;
    closeBtn.onmouseover = () => closeBtn.style.background = 'rgba(255,255,255,0.3)';
    closeBtn.onmouseout = () => closeBtn.style.background = 'rgba(255,255,255,0.2)';
    closeBtn.onclick = () => modalOverlay.remove();

    header.appendChild(title);
    header.appendChild(closeBtn);

    // モーダル本体
    const body = document.createElement('div');
    body.style.cssText = `
        padding: 2rem;
        overflow-y: auto;
        flex: 1;
    `;

    // 記事メタ情報
    const metaInfo = document.createElement('div');
    metaInfo.style.cssText = `
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        padding: 1rem;
        margin-bottom: 1.5rem;
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
        font-size: 0.9rem;
    `;

    const statusText = article.status === 'published' ? '投稿済み' :
                     article.status === 'draft' ? '下書き' : article.status;

    // HTMLエスケープ関数（インライン定義）
    const escapeHtml = (unsafe) => {
        if (typeof unsafe !== 'string') return '';
        return unsafe
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    };

    metaInfo.innerHTML = `
        <div><strong>カテゴリ:</strong> ${escapeHtml(article.category || 'なし')}</div>
        <div><strong>状態:</strong> ${escapeHtml(statusText)}</div>
        <div><strong>文字数:</strong> ${article.word_count || 0}字</div>
        <div><strong>作成日:</strong> ${new Date(article.created_at).toLocaleString('ja-JP')}</div>
        ${article.published_at ? `<div><strong>投稿日:</strong> ${new Date(article.published_at).toLocaleString('ja-JP')}</div>` : ''}
        ${article.keywords && article.keywords.length > 0 ?
          `<div><strong>キーワード:</strong> ${escapeHtml(article.keywords.join(', '))}</div>` : ''}
    `;

    // 記事内容エリア
    const contentArea = document.createElement('div');
    contentArea.style.cssText = `
        background: white;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        max-height: 400px;
        overflow-y: auto;
        line-height: 1.6;
        font-size: 0.95rem;
    `;

    const contentHeader = document.createElement('h3');
    contentHeader.textContent = '記事全文';
    contentHeader.style.cssText = 'margin: 0 0 1rem 0; color: #2c3e50; font-size: 1.1rem;';

    const contentDiv = document.createElement('div');
    // HTMLコンテンツを安全にサニタイズ
    const safeContent = escapeHtml(article.content || '')
        .replace(/\n/g, '<br>')
        .replace(/  /g, ' &nbsp;');
    contentDiv.innerHTML = safeContent;

    contentArea.appendChild(contentHeader);
    contentArea.appendChild(contentDiv);

    // アクションエリア
    const actionArea = document.createElement('div');
    actionArea.style.cssText = 'display: flex; gap: 10px; flex-wrap: wrap; justify-content: flex-end;';

    // コピーボタン
    const copyBtn = document.createElement('button');
    copyBtn.className = 'button';
    copyBtn.style.background = 'linear-gradient(135deg, #17a2b8, #138496)';
    copyBtn.textContent = '内容をコピー';
    copyBtn.onclick = async () => {
        try {
            await navigator.clipboard.writeText(article.content || '');
            showNotification('記事内容をクリップボードにコピーしました', 'success');
        } catch (error) {
            console.error('コピー失敗:', error);
            showNotification('コピーに失敗しました', 'error');
        }
    };
    actionArea.appendChild(copyBtn);

    // 投稿ボタン（下書きの場合のみ）
    if (article.status === 'draft') {
        const publishBtn = document.createElement('button');
        publishBtn.className = 'button';
        publishBtn.style.background = 'linear-gradient(135deg, #28a745, #20c997)';
        publishBtn.textContent = '投稿';
        publishBtn.onclick = () => {
            if (confirm('この記事を投稿しますか？')) {
                publishArticleWithFeedback(article.id, article.title, publishBtn);
                setTimeout(() => {
                    modalOverlay.remove();
                    loadArticles();
                }, 2000);
            }
        };
        actionArea.appendChild(publishBtn);
    }

    // ブログ表示ボタン（投稿済みの場合のみ）
    if (article.blog_url) {
        const viewLink = document.createElement('a');
        viewLink.href = article.blog_url;
        viewLink.target = '_blank';
        viewLink.className = 'button';
        viewLink.textContent = 'ブログで表示';
        viewLink.style.textDecoration = 'none';
        actionArea.appendChild(viewLink);
    }

    // 要素を組み立て
    body.appendChild(metaInfo);
    body.appendChild(contentArea);
    body.appendChild(actionArea);

    modal.appendChild(header);
    modal.appendChild(body);
    modalOverlay.appendChild(modal);

    // ページに追加してモーダルを表示
    document.body.appendChild(modalOverlay);

    // ESCキーでモーダルを閉じる
    const handleEscape = (e) => {
        if (e.key === 'Escape') {
            modalOverlay.remove();
            document.removeEventListener('keydown', handleEscape);
        }
    };
    document.addEventListener('keydown', handleEscape);

    // オーバーレイクリックでモーダルを閉じる
    modalOverlay.onclick = (e) => {
        if (e.target === modalOverlay) {
            modalOverlay.remove();
        }
    };
}

// 既存のviewArticleContent関数を新しいshowArticleContent関数にエイリアス
const viewArticleContent = showArticleContent;