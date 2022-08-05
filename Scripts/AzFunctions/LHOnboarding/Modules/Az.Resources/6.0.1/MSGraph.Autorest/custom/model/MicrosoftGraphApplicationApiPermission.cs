// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// Code generated by Microsoft (R) AutoRest Code Generator.
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

using System;

namespace Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models
{
    /// <summary>Represents an Azure Active Directory user object.</summary>
    public class MicrosoftGraphApplicationApiPermission
    {
        /// <summary>Backing field for <see cref="ApiId" /> property.</summary>
        private Guid? _ApiId;

        /// <summary>
        /// The unique identifier for the resource that the application requires access to.  This should be equal to the appId declared on the target resource application.
        /// </summary>
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Origin(Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.PropertyOrigin.Owned)]
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.FormatTable(Index = 0)]
        public Guid? ApiId { get => this._ApiId; set => this._ApiId = value; }

        /// <summary>Backing field for <see cref="Id" /> property.</summary>
        private Guid? _id;

        /// <summary>
        /// The unique identifier for one of the oauth2PermissionScopes or appRole instances that the resource application exposes.
        /// </summary>
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Origin(Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.PropertyOrigin.Owned)]
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.FormatTable(Index = 1)]
        public Guid? Id { get => this._id; set => this._id = value; }

        /// <summary>Backing field for <see cref="Type" /> property.</summary>
        private string _type;

        /// <summary>
        /// Specifies whether the id property references an oauth2PermissionScopes or an appRole. Possible values are Scope or Role.
        /// </summary>
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Origin(Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.PropertyOrigin.Owned)]
        [Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.FormatTable(Index = 2)]
        public string Type { get => this._type; set => this._type = value; }

    }
}