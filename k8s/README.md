# Traefik (k3s/쿠버네티스)

이 디렉토리는 기존 `docker-compose` 기반 Traefik 설정을 **k3s(쿠버네티스) Ingress Controller**로 옮기기 위한 파일 기반(Helm) 구성을 담는다.

핵심 목표:

- 기존 `traefik/traefik.yaml`(정적 설정)과 `traefik/rules/*.yaml`(동적 라우팅)을 최대한 그대로 가져간다.
- 배포는 Argo CD로 관리한다.
- 초기 단계에서는 Traefik이 아직 없으므로 Argo CD는 NodePort로도(긴급용) 접근 가능하게 유지한다.

## 구성

- `helm/traefik-ingress/`: Traefik Helm(서브차트) + 기존 설정을 ConfigMap으로 주입하는 래퍼 차트
- `argocd-application.yaml`: Argo CD Application 예시(레포 URL은 환경에 맞게 수정)

## 배포(Argo CD)

1) Argo CD에서 `traefik` 네임스페이스에 설치하도록 Application을 생성한다.
2) Application의 `repoURL`을 실제 Git 저장소 URL로 변경한다.

```bash
kubectl apply -f /workspace/hansanghyeon-selfhost/traefik/k8s/argocd-application.yaml
```

## 주의 사항

- 기존 구성에는 `host.docker.internal`을 사용하는 규칙이 있다(예: `traefik/rules/vpn.yaml`). 쿠버네티스에서는 동작하지 않으므로, 해당 규칙은 실제 IP/서비스로 전환해야 한다.
- 인증서/로그/유저 파일은 기존과 동일하게 `_v/traefik/` 경로를 사용하도록 설계되어 있다(노드에 `/workspace`가 바인드되어 있다는 전제).
