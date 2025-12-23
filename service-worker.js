// 缓存名称和版本号
const CACHE_NAME = 'christmas-galaxy-cache-v1';

// 需要缓存的资源列表
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json',
  '/assets/textures/snowflake1.png',
  '/libs/three/build/three.module.js',
  '/libs/three/examples/jsm/controls/OrbitControls.js',
  '/libs/three/examples/jsm/environments/RoomEnvironment.js',
  '/libs/three/examples/jsm/loaders/FontLoader.js',
  '/libs/three/examples/jsm/geometries/TextGeometry.js',
  '/libs/three/examples/jsm/math/MeshSurfaceSampler.js',
  '/libs/mediapipe/camera_utils.js',
  '/libs/mediapipe/control_utils.js',
  '/libs/mediapipe/drawing_utils.js',
  '/libs/mediapipe/hands.js',
  '/music/we_wish_you_a_merry_christmas.mp3',
  '/music/jingle_bells.mp3',
  '/music/deck_the_halls.mp3',
  '/music/silent_night.mp3'
];

// 安装service worker并缓存资源
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Opened cache');
        return cache.addAll(urlsToCache);
      })
  );
});

// 激活service worker并清理旧缓存
self.addEventListener('activate', (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// 拦截网络请求，优先从缓存返回资源
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // 如果缓存中有资源，直接返回
        if (response) {
          return response;
        }
        // 否则发起网络请求
        return fetch(event.request).then(
          (response) => {
            // 检查响应是否有效
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // 克隆响应对象，因为响应流只能使用一次
            const responseToCache = response.clone();
            
            // 将新请求的资源添加到缓存
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          }
        );
      }
    )
  );
});

// 支持推送通知
self.addEventListener('push', (event) => {
  const data = event.data.json();
  const options = {
    body: data.body,
    icon: 'assets/textures/snowflake1.png',
    badge: 'assets/textures/snowflake1.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: '1'
    },
    actions: [
      {
        action: 'explore',
        title: 'Explore the Galaxy'
      },
      {
        action: 'close',
        title: 'Close'
      }
    ]
  };
  
  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});

// 处理通知点击事件
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});