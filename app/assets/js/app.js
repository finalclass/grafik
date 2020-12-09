/*global localStorage*/
import '../css/app.css';
import 'phoenix_html';
import { Elm } from '../elm/src/Main.elm';

const storageKey = 'grafik-dashboard';
const app = Elm.Main.init({
    flags: "{}"
});

app.ports.localStoragePutItem.subscribe(message => {
    const obj = JSON.parse(message);
    localStorage.setItem(obj.key, obj.message);
});

app.ports.localStorageGetItem.subscribe(key => {
    app.ports.localStorage.send(JSON.stringify({
        key,
        value: localStorage.getItem(key)
    }));
});

window.addEventListener('storage', function(event) {
    if (event.storageArea === localStorage) {
        app.ports.localStorage.send(JSON.stringify({
            key: event.key,
            value: event.newValue
        }));
    }
}, false);
