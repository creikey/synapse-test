extends Button

var tool_object: ToolBase = null

func init_from_tool(t: ToolBase):
	tool_object = t
	text = t.tool_name
