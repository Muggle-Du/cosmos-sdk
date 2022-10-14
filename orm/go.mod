module github.com/cosmos/cosmos-sdk/orm

go 1.17

require (
	github.com/cosmos/cosmos-proto v1.0.0-alpha8
	github.com/cosmos/cosmos-sdk/api v0.1.0-alpha1
	github.com/cosmos/cosmos-sdk/errors v1.0.0-beta.2
	google.golang.org/protobuf v1.28.1
	gotest.tools/v3 v3.1.0
	pgregory.net/rapid v0.5.3
)

require (
	github.com/google/go-cmp v0.5.9 // indirect
	github.com/pkg/errors v0.9.1 // indirect
)

replace github.com/gogo/protobuf => github.com/regen-network/protobuf v1.3.3-alpha.regen.1
