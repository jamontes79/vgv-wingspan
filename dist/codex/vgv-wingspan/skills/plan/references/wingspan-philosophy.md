# Wingspan Philosophy

Apply VGV's best practices and standards for scalable software to AI-assisted
workflows. Each step of the development cycle should make subsequent steps
clearer and closer to the user's intent: build the right thing, then build the
thing right.

Wingspan is technology-agnostic by design. It handles the software development
lifecycle: brainstorming, planning, building, reviewing, hotfixing, and
debriefing. It should not enforce one programming language, framework, or
toolchain.

Technology-specific concerns such as linting, formatting, scaffolding, and
framework conventions belong in companion plugins or the host project's own
tooling. Wingspan should discover and respect those local conventions instead
of inventing new ones.
