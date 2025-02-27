package mint_test

import (
	"testing"
	"time"

	"github.com/Nolus-Protocol/nolus-core/app/params"
	"github.com/Nolus-Protocol/nolus-core/testutil/nullify"
	"github.com/Nolus-Protocol/nolus-core/testutil/simapp"
	"github.com/Nolus-Protocol/nolus-core/x/mint"
	"github.com/Nolus-Protocol/nolus-core/x/mint/types"
	"github.com/stretchr/testify/require"
	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"
)

func TestGenesis(t *testing.T) {
	params.SetAddressPrefixes()
	app, err := simapp.TestSetup()
	if err != nil {
		t.Errorf("Error while creating simapp: %v\"", err)
	}
	blockTime := time.Now()
	header := tmproto.Header{Height: app.LastBlockHeight() + 1}
	ctx := app.BaseApp.NewContext(false, header).WithBlockTime(blockTime)
	minterKeeper := app.MintKeeper

	genesisState := types.GenesisState{
		Params: types.DefaultParams(),
	}

	acc := app.AccountKeeper
	mint.InitGenesis(ctx, minterKeeper, acc, &genesisState)
	got := mint.ExportGenesis(ctx, minterKeeper)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)
}
