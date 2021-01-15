Istio doesn't have public accessible helm chart.  
You need to download istio-release from the official site and copy istio-operator helm chart here.

```bash
curl -L https://istio.io/downloadIstio | sh -
cp -r istio-1.8.2/manifests/charts/istio-operator helm-charts/istio
```