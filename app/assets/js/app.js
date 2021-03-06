/*global localStorage*/
// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.css';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Elm } from '../elm/src/Main.elm';

const elmMain = document.getElementById('elm-main');
if (elmMain) {
    const storageKey = 'grafik-dashboard';
    
    const app = Elm.Main.init({
        node: elmMain,
        flags: localStorage.getItem(storageKey) || "{}"
    });
    
    app.ports.expandedProjectsCache.subscribe(function(val) {
        localStorage.setItem(storageKey, JSON.stringify(val));
    });
 }

