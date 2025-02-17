extends Node

var _errors = []

func capture(title, description, should_dump_stack=false):
	var screenshot = await Screenshot.capture()
	print(screenshot)
	if description == null:
		description = title
	
	_errors.append({
		"title": title,
		"body": build_issue_body(description, should_dump_stack),
	})

func report(title, description, should_dump_stack=false):
	if description == null:
		description = title
	var body = build_issue_body(description, should_dump_stack)
	var err = OS.shell_open(new_issue_url(title, body))
	# Print OS.shell_open() errors, but don't report them.
	# That's how infinite recursion happens.
	Console.error("BugReporter.report(): OS.shell_open() encountered an error", err, false)

func build_issue_body(body_prefix, should_dump_stack=false, stack_skip=1):
	var build_logs = BuildInfo.cirrus_url
	
	if build_logs == null:
		build_logs = "(Not available.)"
	
	var stack_dump = []
	if should_dump_stack:
		stack_dump = [
			"", "",
			"```",
			dump_stack(stack_skip + 1),
			"```",
		]
	
	var body = "\n".join(PackedStringArray([
		body_prefix
		] + stack_dump + [
		"", "",
		"Game version: %s (%s)" % [BuildInfo.version, BuildInfo.build_hash],
		"Source for this build: %s" % [BuildInfo.source_url],
		"Build logs: %s" % [build_logs],
	]))
	
	return body

func new_issue_url(title, body):
	var base_url = "https://github.com/duckinator/keress/issues/new"
	title = title.uri_encode()
	body = body.uri_encode()
	
	return base_url + "?title=" + title + "&body=" + body

func dump_stack(stack_skip=1):
	var i = 0
	var stack_str = "Stack:\n"
	for item in get_stack():
		if i < stack_skip:
			i += 1
			continue
		stack_str += "  %s:%s in function '%s'\n" % [item.source, item.line, item.function]

	return stack_str
