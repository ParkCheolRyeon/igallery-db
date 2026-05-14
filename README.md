# igallery-db

iGallery 백엔드용 PostgreSQL 스키마/쿼리/sqlc 출력을 모아둔 Go 모듈.

별도 git tag(`vMAJOR.MINOR.PATCH`)로 버저닝하며 `go get`으로 가져다 사용한다.

## 구성

```
.
├── go.mod
├── sqlc.yml
├── migrations/   # golang-migrate 형식 (up/down)
├── queries/      # sqlc 입력 SQL
└── db/           # sqlc 출력 (package db)
```

## 호스트 앱에서 사용

```bash
go get github.com/ParkCheolRyeon/igallery-db@v0.1.0
```

```go
import "github.com/ParkCheolRyeon/igallery-db/db"

q := db.New(pool)
user, err := q.GetUser(ctx, id)
```

### Private repo 인증

private repo인 경우 호스트 앱 환경에 다음 설정 필요:

```bash
export GOPRIVATE=github.com/ParkCheolRyeon/*
git config --global url."git@github.com:".insteadOf "https://github.com/"  # SSH
# 또는 ~/.netrc 에 GitHub PAT
```

GitHub Actions에서는:

```yaml
- name: Configure Go private module access
  env:
    GH_PAT: ${{ secrets.GO_MODULES_PAT }}
  run: |
    git config --global url."https://x-access-token:${GH_PAT}@github.com/".insteadOf "https://github.com/"
    echo "GOPRIVATE=github.com/ParkCheolRyeon/*" >> $GITHUB_ENV
```

## 변경 절차

1. `queries/` 또는 `migrations/` 수정
2. `sqlc generate` — `db/` 갱신
3. 생성물까지 함께 커밋
4. 릴리즈 단위에서 태깅:

   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```

## 마이그레이션 적용

로컬:

```bash
migrate -path migrations -database "$DATABASE_URL" up
```

운영 환경 적용(Snapshot + CodeBuild/SSM tunnel 등)은 별도 워크플로우로 분리 예정.
