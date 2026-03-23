---
description: "Generate comprehensive explanation from chat history and any files referenced"
---

By referencing any file(s) specified and this chat history, explain step by step, in a markdown document called `chat-tutorial-summary.md`, how you would guide someone with minimal subject matter knowledge how to troubleshoot and arrive at the solution or fix.

Explain each step you did, such as:

1. **Checking logs and searching for specific phrases in files**
   - What commands were run and why
   - What you were looking for at each step
   - Why those specific checks were chosen

2. **Understanding the execution flow**
   - How you traced through the code
   - What patterns you identified
   - How you mapped the call stack

3. **Hypotheses and indicators**
   - What were the possible hypotheses at each stage
   - What indicators and evidence were encountered
   - How hypotheses were validated or eliminated

4. **Solution evaluation**
   - What were all the possible solutions considered
   - Detailed pros and cons of each approach
   - Why you chose the specific solution over alternatives

5. **Implementation details**
   - Step-by-step code changes with explanations
   - Why each change was necessary
   - Before/after comparisons showing the fix

6. **Key learnings and best practices**
   - General principles extracted from this case
   - Best practices for preventing similar issues
   - Debugging strategies that can be reused

Think hard and elaborate thoroughly. Create a document that serves as both a comprehensive learning resource and a practical debugging reference for future developers.

The walkthrough should be educational enough for someone with minimal subject matter knowledge to understand both the specific problem and the general solution methodology.
