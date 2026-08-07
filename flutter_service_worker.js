'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "359073c61637046d0f55cf349d6acced",
"index.html": "454eae6cba6a77c89422a49d5ac5994b",
"/": "454eae6cba6a77c89422a49d5ac5994b",
"main.dart.js": "3bc8b16554e073318c0184802e0ce40d",
"version.json": "746caf28747614f701b58c4bfacb0d4e",
"assets/assets/images/rawbank_yt_EQb7RmbYRug.jpg": "b50eaaef1cf3ffadb441492fba3bcb0e",
"assets/assets/images/rawbank_identity.jpg": "e6fc450df317caba50e0b8c6a697b67b",
"assets/assets/images/rawbank_yt_IznG3OpfWjk.jpg": "8f02932d7edda71a61e773e11be18e70",
"assets/assets/images/rawbank_yt_FM3hHkllxQ4.jpg": "85f0942ba5a67fe2eff354cc1b621978",
"assets/assets/images/rawbank_digital.png": "2ff90b712eb7a046950af92164b6eb5c",
"assets/assets/images/rawbank_icon.png": "81181480479d2048b518c75a656b3142",
"assets/assets/images/rawbank_yt_0DAoXIE9MWA.jpg": "72b6b0c5ac8adccf18954c0518715931",
"assets/assets/images/rawbank_logo.png": "03f746aa621f5ed506ed241ff9a816ad",
"assets/assets/images/rawbank_yt_4ryJSSlq4kw.jpg": "19ca87e0b8a3589a9f21a514c110220d",
"assets/assets/images/rawbank_yt_HWQZQLBoKew.jpg": "156785d391bcdae25202d8f2646086d4",
"assets/assets/images/rawbank_yt_0hEBRfKidhI.jpg": "92cd141f064cc513f6af1f1ee2b03859",
"assets/assets/images/rawbank_yt_5Y-mbJqvc_E.jpg": "19c3d21d0dd9acc84f231e600550c6fd",
"assets/assets/images/rawbank_yt_4tof-5c3nzQ.jpg": "f341233ff502a52e19850574071613bf",
"assets/assets/images/rawbank_brand.jpg": "e6934bc4db78bfcff97848e178c6afee",
"assets/assets/images/rawbank_ceo.jpg": "4dc7cd4f401cc1c8ad33f42d1f1b69d8",
"assets/assets/images/rawbank_yt_AAQBKi8mzUI.jpg": "c0a0eb80a9a9c4f7bfaf44c219efcc23",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/fonts/MaterialIcons-Regular.otf": "af5f5ae8cb9acf80148bd3e0e918a21e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "c24462eccbd5d381a6adbf2df9eae899",
"assets/AssetManifest.bin": "0f1daef2418ef57acf42d3d09c6caa24",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "2cd53139cc5c3307f76f9c6a58f8cd64",
"assets/AssetManifest.bin.json": "64d42a391bf42d8571be7e631d718d62",
"favicon.png": "a8df410e0dd8132ca80456623263d930",
"icons/Icon-maskable-192.png": "639da763549ad0077376e2881d37e737",
"icons/Icon-maskable-512.png": "ad18b53c46a627e1f36b6cad05adb9fa",
"icons/Icon-512.png": "6b55f568cb45cc6b193dd1852b0110a9",
"icons/Icon-192.png": "5c4b2dae747030be10ee6ece9785915c",
"manifest.json": "d63d99f8e5923a7bc22c3c501ba162f8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
