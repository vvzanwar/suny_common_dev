# experience-ui-bundle-frontend-generate - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```js
const basename = document.querySelector('base')
  ? new URL(document.querySelector('base').href).pathname.replace(/\/$/, '')
  : '/';
const router = createBrowserRouter(routes, { basename });
```
