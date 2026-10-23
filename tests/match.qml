import QtQuick
import "../Twilight/Launcher/search/Match.js" as Match

// Tests for the launcher's search. Needs only Qt's qml tool:
//     QT_QPA_PLATFORM=offscreen qml tests/match.qml
// Exits with a non-zero code when a check fails.
Item {
    Component.onCompleted: {
        try {
            run();
        } catch (e) {
            console.log("FAIL exception:", e);
            Qt.exit(1);
        }
    }

    function run() {
        let pass = 0, fails = 0;
        const eq = (name, got, want) => {
            const g = JSON.stringify(got), w = JSON.stringify(want);
            if (g === w) pass++; else { fails++; console.log("FAIL", name, "\n  got ", g, "\n  want", w); }
        };

        const app = (name, extra = {}) => Object.assign({ name, genericName: "", comment: "", keywords: [], categories: [] }, extra);
        const names = list => list.map(a => a.name);

        const firefox = app("Firefox", { genericName: "Web Browser", keywords: ["internet", "www"], categories: ["Network"] });
        const code = app("Visual Studio Code", { comment: "Code editing", categories: ["Development"] });
        const files = app("Files", { genericName: "File Manager" });
        const terminal = app("Terminal", { genericName: "Terminal emulator" });
        const gimp = app("GNU Image Manipulation Program", { keywords: ["photo"] });
        const all = [firefox, code, files, terminal, gimp];

        // an empty query lists everything, in the order it came
        eq("empty query", names(Match.search(all, "")), names(all));
        eq("blank query", names(Match.search(all, "   ")), names(all));
        eq("empty query is the same list", Match.search(all, "") === all, true);

        // where the query matches decides the order
        eq("start of the name", names(Match.search(all, "fir")), ["Firefox"]);
        eq("start of a word", names(Match.search(all, "stu")), ["Visual Studio Code"]);
        eq("start of the last word", names(Match.search(all, "code")), ["Visual Studio Code"]);
        eq("inside a word", names(Match.search(all, "refo")), ["Firefox"]);
        eq("case doesn't matter", names(Match.search(all, "FIREFOX")), ["Firefox"]);
        eq("spaces around are ignored", names(Match.search(all, "  firefox ")), ["Firefox"]);

        // the other fields of the entry
        eq("generic name", names(Match.search(all, "browser")), ["Firefox"]);
        eq("keyword", names(Match.search(all, "photo")), ["GNU Image Manipulation Program"]);
        eq("category", names(Match.search(all, "development")), ["Visual Studio Code"]);
        eq("comment", names(Match.search(all, "editing")), ["Visual Studio Code"]);

        // the letters in order, with gaps
        eq("fuzzy", names(Match.search(all, "ffx")), ["Firefox"]);
        eq("fuzzy needs the order", names(Match.search(all, "xff")), []);

        // better matches come first
        const ranked = Match.search([app("Moon Files"), app("Profiles"), app("Files"), app("Other", { comment: "files" })], "files");
        eq("ranking", names(ranked), ["Files", "Moon Files", "Profiles", "Other"]);

        // nothing matches
        eq("no match", names(Match.search(all, "zzzz")), []);
        eq("no apps", Match.search([], "fire"), []);

        // typed with the Russian layout on
        eq("translit", Match.translit("ашкуащч"), "firefox");
        eq("translit of the keys left of 1 and the brackets", Match.translit("ёхъжэбю"), "`[];',.");
        eq("translit keeps the rest", Match.translit("a-б 1"), "a-, 1");
        eq("firefox in the Russian layout", names(Match.search(all, "ашкуащч")), ["Firefox"]);
        eq("terminal in the Russian layout", names(Match.search(all, "еукьштфд")), ["Terminal"]);
        eq("a Russian name still matches as typed", names(Match.search([app("Телеграм")], "теле")), ["Телеграм"]);

        console.log("MATCH TESTS:", pass, "passed,", fails, "failed");
        Qt.exit(fails === 0 ? 0 : 1);
    }
}
