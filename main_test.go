package main

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestEcho(t *testing.T) {
	//Test happy path
	err := echo([]string{"bin-name", "arg1", "arg2"})
	require.NoError(t, err)
}

func TestEchoErrorNoArgs(t *testing.T) {
	// Test empty arguments
	err := echo([]string{})
	require.Error(t, err)
}
