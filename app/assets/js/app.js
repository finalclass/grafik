/*global localStorage*/
import '../css/app.css';
import 'phoenix_html';
import { Elm } from '../elm/src/Main.elm';

const storageKey = 'grafik-dashboard';
const app = Elm.Main.init({
    flags: localStorage.getItem(storageKey) || "{}"
});

// const externalApi = {
//     localStorage: ({ key, value }) => localStorage.setItem(key, JSON.stringify(value))
// };

// app.ports.externalApi.subscribe(msg => externalApi[msg.type](msg));

//  window.addEventListener('storage', function(event) {
//      if (event.storageArea === localStorage) {
//          app.ports.externalApi.send({
//              type: 'localStorage',
//              key: event.key,
//              value: event.newValue
//          });
//      }
//  }, false);
