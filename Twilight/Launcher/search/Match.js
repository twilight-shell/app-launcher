.pragma library

// Keys of the Russian layout mapped to the same keys on QWERTY, so a query
// typed with the wrong layout active ("firefox" in RU) still matches.
const ruToEn = {
    "й": "q", "ц": "w", "у": "e", "к": "r", "е": "t", "н": "y", "г": "u", "ш": "i", "щ": "o", "з": "p",
    "х": "[", "ъ": "]", "ф": "a", "ы": "s", "в": "d", "а": "f", "п": "g", "р": "h", "о": "j", "л": "k",
    "д": "l", "ж": ";", "э": "'", "я": "z", "ч": "x", "с": "c", "м": "v", "и": "b", "т": "n", "ь": "m",
    "б": ",", "ю": ".", "ё": "`"
};

function translit(text) {
    return Array.from(text).map(c => ruToEn[c] ?? c).join("");
}

function score(app, q) {
    const name = app.name.toLowerCase();
    if (name.startsWith(q))
        return 100;
    if (name.split(/[\s\-_.]+/).some(word => word.startsWith(q)))
        return 80;
    if (name.includes(q))
        return 60;

    const extra = [app.genericName, app.comment, ...app.keywords, ...app.categories].join(" ").toLowerCase();
    if (extra.includes(q))
        return 40;

    // Letters of the query appear in the name in order: "ffx" -> "firefox".
    let i = 0;
    for (const c of name) {
        if (c === q[i])
            i++;
    }
    return i === q.length ? 20 : 0;
}

// `apps` filtered by `text` and sorted best match first; all of them when the
// query is empty.
function search(apps, text) {
    const q = text.trim().toLowerCase();
    if (q === "")
        return apps;

    const alt = translit(q);
    return apps
        .map(app => ({ app, score: Math.max(score(app, q), alt !== q ? score(app, alt) : 0) }))
        .filter(r => r.score > 0)
        .sort((a, b) => b.score - a.score)
        .map(r => r.app);
}
