# Minime Factory Aragon App

This, along with the [minime app](https://github.com/Recoblix/minime-app) is a clone of the [minime token](https://github.com/Giveth/minime) created by Giveth, but implemented as Aragon Apps. This allows:

- Upgradability controlled by a Smart Organization
- Permissions for various aspects of the token like create and destroy to be handeled independently from each other using Aragon's permission manager
- All clone tokens are implemented as proxy contracts reducing gas costs
- As Aragon Apps, these can be included in kits on the deployment of new Smart Organizations
