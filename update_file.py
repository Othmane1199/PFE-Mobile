import re

with open("lib/features/services/presentation/services_screen.dart", "r") as f:
    content = f.read()

# 1. Add import
if "import '../../../core/models/client.dart';" not in content:
    content = content.replace(
        "import '../../../core/models/service.dart';",
        "import '../../../core/models/service.dart';\nimport '../../../core/models/client.dart';"
    )

# 2. Update _showServiceDialog signature and body
content = re.sub(
    r"void _showServiceDialog\(\[ServiceTask\? serviceTask\]\) \{",
    """void _showServiceDialog(List<Client> clients, [ServiceTask? serviceTask]) {
    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a client first')),
      );
      return;
    }""",
    content
)

# 3. Replace clientIdCtrl with selectedClientId
content = re.sub(
    r"final clientIdCtrl = TextEditingController.*?;\s*",
    "String? selectedClientId = serviceTask?.clientId ?? (clients.isNotEmpty ? clients.first.id : null);\n    if (selectedClientId != null && !clients.any((c) => c.id == selectedClientId)) {\n      selectedClientId = clients.isNotEmpty ? clients.first.id : null;\n    }\n",
    content
)

# 4. Replace TextField for Client ID with DropdownButtonFormField
content = re.sub(
    r"TextField\(\s*controller: clientIdCtrl,\s*decoration: const InputDecoration\(labelText: 'Client ID'\),\s*\),",
    """DropdownButtonFormField<String>(
                      value: selectedClientId,
                      decoration: const InputDecoration(labelText: 'Client'),
                      items: clients.map((client) {
                        return DropdownMenuItem(
                          value: client.id,
                          child: Text(client.nameOrCompany),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setStateDialog(() => selectedClientId = val);
                      },
                    ),""",
    content
)

# 5. Fix newService parameter
content = re.sub(
    r"clientId: clientIdCtrl\.text,",
    "clientId: selectedClientId ?? '',",
    content
)

# 6. Update build method to fetch clients and pass to _showServiceDialog
content = re.sub(
    r"final servicesAsync = ref\.watch\(servicesProvider\);",
    "final servicesAsync = ref.watch(servicesProvider);\n    final clientsAsync = ref.watch(clientsProvider);\n    final clients = clientsAsync.value ?? [];",
    content
)

# Update calls to _showServiceDialog
content = re.sub(
    r"_showServiceDialog\(service\)",
    "_showServiceDialog(clients, service)",
    content
)
content = re.sub(
    r"_showServiceDialog\(\)",
    "_showServiceDialog(clients)",
    content
)

with open("lib/features/services/presentation/services_screen.dart", "w") as f:
    f.write(content)

