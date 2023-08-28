package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	tfjson "github.com/hashicorp/terraform-json"
)

func TestTerraformPlan(t *testing.T) {
	planJSON, err := os.ReadFile("../plan.json")
	if err != nil {
		t.Fatal(err)
	}

	plan, err := terraform.ParsePlanJSON(string(planJSON))
	if err != nil {
		t.Fatal(err)
	}

	for _, change := range plan.ResourceChangesMap {
		for _, action := range change.Change.Actions {
			if action == tfjson.ActionDelete {
				t.Errorf("Plan contains problematic delete action for resource %s", change.Address)
			}
		}
	}
}
