/*global localStorage*/
import '../css/app.css';
import 'phoenix_html';
import { Elm } from '../elm/src/Main.elm';

const storageKey = 'grafik-dashboard';
const app = Elm.Main.init({
    flags: localStorage.getItem(storageKey) || "{}"
});
    
// app.ports.commonPort.subscribe(function(msg) {
//     switch (msg.type) {
//     case "setExpandedProjects":
//         localStorage.setItem(storageKey, JSON.stringify(msg.value));
//         break;
//     }
// });

