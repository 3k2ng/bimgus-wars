# bimgus-wars

## AI compressor generation:

### Prompts used to generate the encoder files in Python
- https://chatgpt.com/share/6722e44d-d9e4-8004-b9be-2b2ebd7c1e3f
- https://chatgpt.com/share/6722e51e-6e38-8004-bf20-fe6098e14500

### Prompts used to generate the decoder in assembly:
- https://aiarchives.org/id/k8NA8sBhl1fLgq5i03Cv

### Manual modifications to AI generated Source Files

- Indenting: minor changes to the line indenting as well
as spacing were done to get the source files to run
- Decoder logic: in the assembly code decoder there is a branch that checks
if the count value is equal to `0x7f`. This caused problems with the Python encoder. Some of the code in the Python encoder had to be manually changed to account
for this.
