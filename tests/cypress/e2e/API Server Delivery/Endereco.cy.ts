describe('Rotas Endereço', () => {

    let idEndereco01:number;
    let idEndereco02:number;

    before(() => {
        cy.request({
            method: 'POST',
            url: '/clientes',
            body: {
                "nome": "Priscila G. Vieira",
                "contato": "55229785634"
            }, failOnStatusCode: false
        });
    });

    it('Criar Endereço - 01', () => {
        cy.request({
            method: 'POST',
            url: '/clientes/55229785634/enderecos',
            body: {
                "id": 0,
                "cliente": 4,
                "rua": "Av. Country Clube dos Engenheiros",
                "numero": "2042",
                "bairro": "Clube dos Engenheiros",
                "complemento": "Casa 120",
                "cidade": "Araruama",
                "estado": "RJ"
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Endereço adicionado com sucesso!');
            expect(Response.body[1].rua).to.equal('Av. Country Clube dos Engenheiros');
            expect(Response.body[1].bairro).to.equal('Clube dos Engenheiros');
            idEndereco01 = Response.body[1].id;
        });
    });

    it('Criar Endereço - 02', () => {
        cy.request({
            method: 'POST',
            url: '/clientes/55229785634/enderecos',
            body: {
                "id": 0,
                "rua": "rua Érica Reis",
                "numero": "35",
                "bairro": "Outeiro",
                "complemento": "Casa 4",
                "cidade": "Belford Roxo",
                "estado": "RJ"
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Endereço adicionado com sucesso!');
            expect(Response.body[1].rua).to.equal('rua Érica Reis');
            expect(Response.body[1].bairro).to.equal('Outeiro');
            idEndereco02 = Response.body[1].id;
        });
    });

    it('Buscar endereços de cliente', () => {
        cy.request('/clientes/55229785634/enderecos')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.contato).to.equal('55229785634');
                expect(Response.body.enderecos[0].rua).to.equal('Av. Country Clube dos Engenheiros');
                expect(Response.body.enderecos[1].rua).to.equal('rua Érica Reis');
            });
    });

    it('Buscar endereço por id = 1', () => {
        cy.request(`/clientes/55229785634/enderecos/${idEndereco01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idEndereco01);
            expect(Response.body.rua).to.equal('Av. Country Clube dos Engenheiros');
            expect(Response.body.bairro).to.equal('Clube dos Engenheiros');
            expect(Response.body.cidade).to.equal('Araruama');
        });
    });

    it('Buscar endereço por id = 2', () => {
        cy.request(`/enderecos/${idEndereco02}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idEndereco02);
            expect(Response.body.rua).to.equal('rua Érica Reis');
            expect(Response.body.bairro).to.equal('Outeiro');
            expect(Response.body.cidade).to.equal('Belford Roxo');
        });
    });

    it('Update endereço - 01', () => {
        cy.request({
            method: 'PUT',
            url: `/clientes/55229785634/enderecos/${idEndereco01}`,
            body: {
                "id": 1,
                "rua": "rua dos Gaúchos",
                "numero": "200",
                "bairro": "Vila Capri",
                "complemento": "",
                "cidade": "Araruama",
                "estado": "RJ"
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Endereço atualizado com sucesso!');
            expect(Response.body[1].rua).to.equal('rua dos Gaúchos');
            expect(Response.body[1].bairro).to.equal('Vila Capri');
            expect(Response.body[1].cidade).to.equal('Araruama');
        });
    });

    it('Update endereço - 02', () => {
        cy.request({
            method: 'PUT',
            url: `/enderecos/${idEndereco02}`,
            body: {
                "id": 2,
                "rua": "rua Nosso Senhor do Calvário",
                "numero": "69",
                "bairro": "Parque Amorim",
                "complemento": "",
                "cidade": "Belford Roxo",
                "estado": "RJ"
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Endereço atualizado com sucesso!');
            expect(Response.body[1].rua).to.equal('rua Nosso Senhor do Calvário');
            expect(Response.body[1].bairro).to.equal('Parque Amorim');
            expect(Response.body[1].cidade).to.equal('Belford Roxo');
        });
    });


    it('Delete endereço 01', () => {
        cy.request({
            method: 'DELETE',
            url: `/clientes/55229785634/enderecos/${idEndereco01}`
        }).then(Response => {
            expect(Response.status).to.equal(202);
            expect(Response.body.message).to.equal('Endereço excluído!');
        });
    });

    it('Delete endereço 02', () => {
        cy.request({
            method: 'DELETE',
            url: `/enderecos/${idEndereco02}`
        }).then(Response => {
            expect(Response.status).to.equal(202);
            expect(Response.body.message).to.equal('Endereço excluído!');
        });
    });

    after(() => {
        cy.request({
            method: 'DELETE',
            url: '/clientes/55229785634',
            failOnStatusCode: false
        });
    });

});